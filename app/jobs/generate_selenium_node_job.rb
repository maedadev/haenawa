class GenerateSeleniumNodeJob
  include HaenawaConst

  @queue = :normal

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    @system_setting = SystemSetting.first
    selenium_package_dir = File.join(SELENIUM_DIR, 'selenium-2.53')

    Rails.logger.info "Seleniumノード用パッケージを作成します。#{options}"

    bat = File.join('lib', 'selenium', 'run_node.bat.erb')
    4.times do |i|
      @port = 5555 + i
      File.write(File.join(selenium_package_dir, "run_node-#{i+1}.bat"), ERB.new(File.read(bat), 0, '-').result(binding))
    end

    selenium_zip = File.join(SELENIUM_DIR, 'selenium-2.53.zip')
    unless system("cd #{File.dirname(selenium_package_dir)} && zip -FSr #{selenium_zip} #{File.basename(selenium_package_dir)}")
      raise "#{selenium_zip} の作成に失敗しました。"
    end

    Rails.logger.info "Seleniumノード用パッケージを作成しました。#{options}"
  end

end
