class StepsController < ApplicationController
  before_action :find_scenario, only: %i[index create]
  before_action :find_step, except: %i[index create]
  before_action :set_scenario, except: %i[index create]
  before_action :set_project

  def index
  end

  def show
    image_path = @step.steppable.screenshot_path_for(@step.step_no)
    if File.exist?(image_path)
      filename = "img-#{@step.steppable.id}-#{'%02d' % @step.step_no}.png"
      send_file(image_path, filename: filename, disposition: 'inline')
    else
      send_file File.join('app', 'assets', 'images', 'loading.gif')
    end
  end

  def create
    step_attrs = Step.default_attrs.merge(step_no: params[:step_no])
    step = @scenario.steps.build(step_attrs)
    ActiveRecord::Base.transaction do
      step.save!
      @scenario.touch
    end
    render :index
  end

  def edit
  end

  def update
    @step.attributes = step_params
    begin
      @step.save!
      @scenario.touch
      redirect_to @scenario
    rescue ActiveRecord::RecordInvalid
      render :edit
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @step.remove_from_list
      @step.update_attribute(:deleted, true)
      @scenario.touch
    end
    render :index
  end

  private

  def step_params
    params.require(:step).permit(:command, :target, :value, :comment)
  end

  def find_scenario
    @scenario = Scenario.find(params[:scenario_id])
  end

  def find_step
    @step = Step.find(params[:id])
  end

  def set_scenario
    @scenario = @step.steppable.scenario
  end

  def set_project
    @project = @scenario.project
  end
end
