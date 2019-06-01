module ProjectsSupport

  def project
    if @_project.nil?
      assert @_project = Project.not_deleted.first
    end
    
    @_project
  end

  def project_params
    {
      :name => SecureRandom.uuid,
      :use_redmine => '1',
      :redmine_host => 'redmine.example.com',
      :redmine_api_key => 'api_key_abcdefg',
      :redmine_identifier => 'haenawa'
    }
  end

end