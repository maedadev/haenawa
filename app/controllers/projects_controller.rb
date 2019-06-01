class ProjectsController < ApplicationController

  def index
    @projects = current_user.my_projects.page(params[:page]).per(10)
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    begin
      @project.transaction do
        @project.save_and_generate_support_env!
      end

      redirect_to @project
    rescue ActiveRecord::RecordInvalid => e
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @project.attributes = project_params

    begin
      @project.transaction do
        @project.save_and_generate_support_env!
      end

      redirect_to @project
    rescue ActiveRecord::RecordInvalid => e
      render :edit
    rescue ActiveRecord::StaleObjectError => e
      @project.errors[:base] << I18n.t('error.messages.stale')
      render :edit
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.attributes = {:deleted => true}

    @project.transaction do
      @project.save!
    end

    redirect_to action: :index
  end

  private

  def default_url_options
    {
      :page => params[:page]
    }
  end

  def project_params
    permitted = [:name, :lock_version, :use_redmine, :redmine_host, :redmine_api_key, :redmine_identifier, :default_build_sequence_code]

    params.require(:project).permit(*permitted)
  end

end
