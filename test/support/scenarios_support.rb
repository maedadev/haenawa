module ScenariosSupport

  def scenario
    if @_scenario.nil?
      assert @_scenario = Scenario.not_deleted.first
      FileUtils.mkdir_p(@_scenario.file.store_dir)
      FileUtils.cp(File.join('test', 'data', @_scenario.original_filename), @_scenario.file.path)
    end
    @_scenario
  end

 def scenario_params
    {
      :name => SecureRandom.uuid,
      :file => Rack::Test::UploadedFile.new("#{Rails.root}/test/data/maeda.html", "text/html", false),
      :project_id => project.id,
    }
  end
end
