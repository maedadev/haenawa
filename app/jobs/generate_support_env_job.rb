class GenerateSupportEnvJob
  @queue = :normal

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    @project = Project.find(options[:project_id])
    
    Rails.logger.info "Cucumberテスト基盤を作成します。#{options}"

    FileUtils.mkdir_p(@project.build_dir)
    FileUtils.cp('Gemfile', File.join(@project.build_dir, 'Gemfile'))
    FileUtils.cp('Gemfile.lock', File.join(@project.build_dir, 'Gemfile.lock'))

    FileUtils.mkdir_p(@project.support_dir)

    suport_files = {
      'env.rb.erb' => 'env.rb',
    }
    suport_files.each do |from, to|
      template = File.join('lib', 'selenium', 'features', 'support', from)
      file = File.join(@project.support_dir, to)
      File.write(file, ERB.new(File.read(template), 0, '-').result(binding))
    end

    Rails.logger.info "Cucumberテスト基盤を作成しました。#{options}"
  end

end
