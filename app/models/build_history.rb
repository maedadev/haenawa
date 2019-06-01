class BuildHistory < ActiveRecord::Base
  belongs_to :scenario

  include Steppable

  after_create :start_test

  enum result: {
    pending: 0,
    passed: 1,
    failed: 2,
    error: 3
  }

  def started_at_string
    return nil unless self.started_at
    self.started_at.to_s(:datetime)
  end

  def finished_at_string
    return nil unless self.finished_at
    self.finished_at.to_s(:datetime)
  end

  def build_path
    Pathname(STORE_BASE_DIR) / "build_histories/#{id}"
  end

  def screenshot_path
    build_path / 'screenshots'
  end

  def screenshot_path_for(step_no)
    screenshot_path / "img_#{step_no}.png"
  end

  def feature_path
    build_path / "features/scenario.feature"
  end

  def started?
    started_at.present?
  end

  def finished?
    finished_at.present?
  end

  def result_string
    I18n.t("text.build_history.results.#{result}")
  end

  def populate_steps!
    scenario.steps.each do |s|
      steps.build(s.attributes.slice('step_no', 'command', 'target', 'value',
                                     'encrypted_value', 'targets',
                                     'raw_targets', 'comment'))
    end
    save!
  end

  def command
    cmd = %w(bundle exec cucumber)

    env = %W(
      SCREENSHOT_DIR=#{screenshot_path}
      APP_HOST=#{scenario.app_host}
      APP_PORT=#{scenario.app_port}
    )

    if SystemSetting.first && SystemSetting.first.selenium_host.present?
      env += %W(
        DEVICE=#{self.device}
        REMOTE=#{SystemSetting.first.selenium_host}
      )
    else
      env += %w(
        DEVICE=headless_chrome
      )
    end

    args = %W(
      --format json --out #{build_result_path}
      --guess
      --no-multiline
      --no-snippets
      --quiet
    )

    cmd + env + args + [feature_path.to_s]
  end

  def step_status(step_no)
    step_result(step_no).dig('status')
  end

  def step_failed?(step_no)
    step_status(step_no) == 'failed'
  end

  def step_skipped?(step_no)
    step_status(step_no) == 'skipped'
  end

  def error_messages
    @error_messages ||= begin
      build_result&.dig(0, 'elements', 0, 'before').to_a.map do |hash|
        hash['result']['error_message']
      end.compact
    end
  end

  def step_message(step_no)
    case step_status(step_no)
    when 'failed'
      step_result(step_no)['error_message']
    end
  end

  class << self
    def build_sequence_code(branches)
      branches.first.build_sequence_code
    end

    def started_at_string(branches)
      return nil if branches.map(&:started_at_string).include?(nil)
      branches.map(&:started_at_string).min
    end

    def finished_at_string(branches)
      return nil if branches.map(&:finished_at_string).include?(nil)
      branches.map(&:finished_at_string).max
    end

    def all_finished?(branches)
      return false if branches.map(&:finished?).include?(false)
      true
    end

    def result_string(branches)
      results = branches.map(&:result)
      if results.include?('error')
        return I18n.t("text.build_history.results.error")
      end
      if results.include?('failed')
        return I18n.t("text.build_history.results.failed")
      end
      if results.include?('pending')
        return I18n.t("text.build_history.results.pending")
      end
      I18n.t("text.build_history.results.passed")
    end

    def processing_time(branches)
      branches.map(&:finished_at).max - branches.map(&:started_at).min
    end
  end

  def update_step_processing_time
    steps.each do |step|
      duration = step_result(step.step_no)['duration'] || 0
      processing_time = (duration / 1_000_000_000.0).round(2)
      step.update(processing_time: processing_time)
    end
  end

  private

  def build_result_path
    build_path / 'result.json'
  end

  def build_result
    @build_result ||= begin
      if build_result_path.exist?
        data = build_result_path.read
        data.blank? ? nil : ActiveSupport::JSON.decode(data)
      end
    end
  end

  def step_result(step_no)
    build_result&.dig(0, 'elements', 0, 'steps', step_no.to_i - 1, 'result') || {}
  end

  def start_test
    JobUtils.add_job(RunScenarioJob, :project_id => scenario.project_id, :scenario_id => scenario.id, :build_history_id => id)
  end

end
