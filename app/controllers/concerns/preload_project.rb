module PreloadProject
  extend ActiveSupport::Concern

  included do
    before_action :preload_project
  end

  protected

  def default_url_options
    {
      :project_id => params[:project_id]
    }
  end

  def preload_project
    @project = Project.find(params[:project_id])
  end

end