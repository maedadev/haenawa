class Scenario < ActiveRecord::Base
  belongs_to :project

  acts_as_list scope: 'project_id = #{project_id} AND deleted = false',
               column: :scenario_no

  validates :name, presence: true
  validates :file, presence: true

  mount_uploader :file, ScenarioUploader

  include Steppable

  has_many :build_histories
  accepts_nested_attributes_for :build_histories

  alias_method :scenario, :itself

  def base_url
    parsed_file.base_url
  end

  def app_host
    base_url.split('://')[1].to_s.split('/')[0]
  end

  def app_port
    ret = base_url.split('://')[2].to_s.split('/')[0]
    if ret.blank?
      ret = '80' if base_url.start_with?('http://')
      ret = '443' if base_url.start_with?('https://')
    end
    ret
  end

  # 最新のビルドの番号（build_no）を取得する。
  # 「ビルド」を表すのはあくまでこのbuild_no。
  def latest_build_no
    @latest_build_no ||= build_histories.maximum(:build_no)
  end

  # .sideファイルの内容へ変換する。
  def to_side_file_content
    result_commands = steps.map(&:to_side_file_content)
    result = JSON.parse(file.file.read, symbolize_names: true)
    result[:tests][0][:commands] = result_commands
    result
  end

  # 特定のビルドのBuildHistoryレコードを取得する。
  # 特定のビルドに所属するBuildHistoryレコードはそのビルドの「ブランチ」と言う。
  # ブランチは対象デバイス毎に作られる。
  def build_branches(build_no)
    build_histories.where(build_no: build_no)
  end

  # 最新のビルドのブランチを取得する。
  def latest_build_branches
    @latest_build_branches ||= build_branches(latest_build_no)
  end

  # 最新のビルドのブランチの内、特定の対象デバイスのブランチを取得する。
  def latest_build_branch(device)
    latest_build_branches.where(device: device).first
  end

  # 最新のビルドのブランチの内、完了したブランチを取得する。
  def latest_build_finished_branches
    @latest_build_finished_branches ||= latest_build_branches.where.not(finished_at: nil)
  end

  # 最新のビルドのブランチの内、ステップ情報がシナリオの状態から乖離したものを取得する。
  def latest_build_stale_branches
    @latest_build_stale_branches ||= latest_build_branches.where("created_at < ?", updated_at)
  end

  def latest_build_stale?
    @latest_build_stale ||= latest_build_stale_branches.any?
  end

  def feature_file
    File.join(project.feature_dir, "scenario_#{id}.feature")
  end

  def steps_file
    File.join(project.feature_dir, 'step_definitions', "scenario_#{id}.rb")
  end

  def test_result_dir
    File.join(project.build_dir, 'test', "scenario_#{id}")
  end

  def parsed_file
    @parsed_file ||= Haenawa::SeleniumScriptParser.run(file)
  end
end
