class BuildNotificationJob
  @queue = :normal

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    @project = Project.find(options[:project_id])
    @scenario = @project.scenarios.find(options[:scenario_id])
    @build_history = @scenario.build_histories.find(options[:build_history_id])

    Rails.logger.info "#{@project.name}／#{@scenario.name} #{@build_history.build_no} を Redmine に登録します。"

    reporter = BuildHistoryReporter.new(:build_history => @build_history)

    params = {
      :issue => {
        :project_id => @project.redmine_project['id'],
        :subject => "#{@project.name}／#{@scenario.name} #{@build_history.build_no}: テストに失敗しました。",
        :description => reporter.render_text
      }
    }

    ret = @project.create_issue(params)
    if ret.status == 201
      Rails.logger.info "#{@project.name}／#{@scenario.name} #{@build_history.build_no} を Redmine に登録しました。"
    else
      Rails.logger.info "#{@project.name}／#{@scenario.name} #{@build_history.build_no} を Redmine に登録できませんでした。"
    end

  end

end
