require 'open3'

class RunScenarioJob
  include HaenawaConst

  @queue = :low

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    # ERBテンプレートからも参照されるインスタンス変数
    @project = Project.find(options[:project_id])
    @scenario = @project.scenarios.find(options[:scenario_id])
    @build_history = @scenario.build_histories.find(options[:build_history_id])

    generate_support_env(options)
    generate_step_definitions(options)
    run_scenario(options)
  end

  def self.generate_support_env(options)
    Rails.logger.info "Cucumberテスト基盤を作成します。#{options}"

    @build_history.build_path.mkpath
    FileUtils.cp(Rails.root / 'Gemfile', @build_history.build_path)
    FileUtils.cp(Rails.root / 'Gemfile.lock', @build_history.build_path)

    support_path = @build_history.build_path / "features/support"
    support_path.mkpath
    support_files = {
      'env.rb.erb' => 'env.rb',
    }
    support_files.each do |from, to|
      template = Rails.root / 'lib/selenium/features/support' / from
      file = support_path / to
      file.write(erb_eval_file(template))
    end

    Rails.logger.info "Cucumberテスト基盤を作成しました。#{options}"
  end

  def self.generate_step_definitions(options)
    Rails.logger.info "Cucumberテストケースを作成します。#{options}"

    feature_template = Rails.root / 'lib/selenium/features/selenium.feature.erb'
    feature_path = @build_history.feature_path
    feature_path.parent.mkpath
    feature_path.write(erb_eval_file(feature_template))

    step_template = Rails.root / 'lib/selenium/features/step_definitions/selenium.rb.erb'
    step_file = @build_history.build_path / "features/step_definitions/scenario_#{@scenario.id}.rb"
    step_file.parent.mkpath
    step_file.write(erb_eval_file(step_template))

    Rails.logger.info "Cucumberテストケースを作成しました。#{options}"
  end

  def self.run_scenario(options)
    Rails.logger.info "RunScenarioJob: テストを開始します。#{options}"

    @build_history.update_columns(:started_at => Time.now)
    begin
      @build_history.screenshot_path.mkpath

      Rails.logger.info "\nテストを実行\n#{@build_history.command.join(' ')}\n"
      _, stderr, status = Open3.capture3(*@build_history.command,
                                         chdir: @build_history.build_path)
      result = case status.exitstatus
      when 0
        Rails.logger.info 'Cucumber: すべてのfeatureは通りました。(終了コード: 0）'
        :passed
      when 1
        Rails.logger.warn 'Cucumber: 通らないfeatureはありました。（終了コード: 1）'
        :failed
      else
        Rails.logger.error "Cucumber: エラーが起きました。（終了コード: #{status.exitstatus}）"
        Rails.logger.error stderr
        :error
      end
    rescue StandardError => e
      result = :error
      raise e
    ensure
      @build_history.update_step_processing_time
      @build_history.update_columns(:finished_at => Time.now, result: BuildHistory.results[result])
    end

    Rails.logger.info "RunScenarioJob: テストを終了しました。#{options}"
  end

  def self.erb_eval_file(erb_file_path)
    erb = ERB.new(erb_file_path.read, 0, '-')
    erb.filename = erb_file_path.to_s
    erb.result(binding)
  end
end
