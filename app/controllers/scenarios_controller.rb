class ScenariosController < ApplicationController
  include SetBuildHistories

  before_action :find_project, only: %i[new create]
  before_action :find_scenario, except: %i[new create]
  before_action :set_project, except: %i[new create]

  def show
    respond_to do |format|
      format.html do
        set_build_histories
      end
      format.side do
        # 旧バージョンのSelenium IDE出力ファイルは考慮していない。

        send_data(JSON.pretty_generate(@scenario.to_side_file_content), filename: @scenario.original_filename, disposition: 'attachment')
      end
    end
  end

  def new
    @scenario = @project.scenarios.build
  end

  def create
    @scenario = @project.scenarios.build(scenario_params)
    begin
      @scenario.save!
      JobUtils.add_job(CreateStepsJob, scenario_id: @scenario.id)
      redirect_to @scenario
    rescue ActiveRecord::RecordInvalid => e
      render :new
    end
  end

  def edit
  end

  def update
    @scenario.attributes = scenario_params
    begin
      @scenario.save!
      redirect_to @scenario
    rescue ActiveRecord::RecordInvalid => e
      render :edit
    end
  end

  def destroy
    @scenario.attributes = {:deleted => true}

    @scenario.transaction do
      @scenario.remove_from_list
      @scenario.save!
    end

    redirect_to @project
  end

  def move_up
    @scenario.move_higher
    redirect_to @project
  end

  def move_down
    @scenario.move_lower
    redirect_to @project
  end

  private

  def scenario_params
    permitted = [:name]
    ret = params.require(:scenario)

    case action_name
    when 'create'
      ret = ret.permit(permitted, :project_id, :file)
    when 'update'
      ret = ret.permit(permitted)
    end

    ret
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def find_scenario
    @scenario = Scenario.find(params[:id])
  end

  def set_project
    @project = @scenario.project
  end
end
