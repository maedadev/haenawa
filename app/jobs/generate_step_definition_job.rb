class GenerateStepDefinitionJob
  include HaenawaConst

  @queue = :normal

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    @project = Project.find(options[:project_id])
    @scenario = @project.scenarios.find(options[:scenario_id])
    
    Rails.logger.info "Cucumberテストケースを作成します。#{options}"

    feature_template = File.join('lib', 'selenium', 'features', 'selenium.feature.erb')
    feature_file = File.join(@project.feature_dir, "scenario_#{@scenario.id}.feature")
    FileUtils.mkdir_p(File.dirname(feature_file))
    File.write(feature_file, ERB.new(File.read(feature_template), 0, '-').result(binding))

    step_template = File.join('lib', 'selenium', 'features', 'step_definitions', 'selenium.rb.erb')
    step_file = File.join(@project.feature_dir, 'step_definitions', "scenario_#{@scenario.id}.rb")
    FileUtils.mkdir_p(File.dirname(step_file))
    File.write(step_file, ERB.new(File.read(step_template), 0, '-').result(binding))

    Rails.logger.info "Cucumberテストケースを作成しました。#{options}"
  end

end
