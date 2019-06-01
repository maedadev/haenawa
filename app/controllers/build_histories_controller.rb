class BuildHistoriesController < ApplicationController
  include SetBuildHistories

  protect_api only: :create
  before_action :find_scenario, only: %i[index create]
  before_action :find_build_history, except: %i[index create]
  before_action :set_scenario, except: %i[index create]
  before_action :set_project

  def index
    set_build_histories
  end

  def show
  end

  def create
    max_no = @scenario.build_histories.maximum('build_no')
    build_no = max_no.nil? ? 1 : max_no + 1
    @created_build_histories = params[:devices].map.with_index(1) do |device, i|
      build_history = @scenario.build_histories.build
      build_history.build_sequence_code = params[:build_sequence_code] || @project.default_build_sequence_code
      build_history.branch_no = i
      build_history.build_no = build_no
      build_history.device = device
      build_history.transaction do
        build_history.populate_steps!
      end
      build_history
    end
    respond_to do |format|
      format.js do
        set_build_histories
        render 'index'
      end
      format.json
    end
  end

  private

  def find_scenario
    @scenario = Scenario.find(params[:scenario_id])
  end

  def find_build_history
    @build_history = BuildHistory.find(params[:id])
  end

  def set_scenario
    @scenario = @build_history.scenario
  end

  def set_project
    @project = @scenario.project
  end
end
