require 'test_helper'

class BuildHistoriesControllerTest < ActionController::TestCase
  def setup
    projects = {
      :projects => [
        {:id => 1, :name => '延縄プロジェクト', :identifier => 'haenawa'}
      ]
    }
    scenarios = {
      :scenarios => [
        {:id => 1, :name => 'シナリオ', project_id: project.id}
      ]
    }

    build_histories = {
      :build_histories => [
        {:id => 1,  scenario_id: scenario.id}
      ]
    }
  end

  def test_一覧
    xhr :get, :index, scenario_id: create(:v2_scenario).id
    assert_response :success
    assert_template :index
    assert assigns(:limit_count)
    assert assigns(:build_histories)
  end

  def test_参照
    get :show, id: build_history.id
    assert_response :success
    assert_template :show
  end

  def test_参照_json
    get :show, id: build_history.id, format: :json
    assert_response :success
    assert_template :show
    assert_equal({
                   id: build_history.id,
                   branch_no: build_history.branch_no,
                   build_no: build_history.build_no,
                   device: build_history.device,
                   result: build_history.result,
                   created_at: build_history.created_at.iso8601(3),
                   updated_at: build_history.updated_at.iso8601(3),
                   started_at: nil,
                   finished_at: nil,
                 }, JSON.parse(@response.body, symbolize_names: true))
  end

  def test_登録
    scenario = create(:v2_scenario)
    assert_difference(-> {scenario.build_histories.count}, 2) do
      xhr :post, :create, scenario_id: scenario.id,
          devices: %w[ie headless_chrome]
    end
    assert_response :success
    assert_template :index
    assert assigns(:created_build_histories)
    assert assigns(:build_histories)
  end

  def test_登録_json
    request.headers['HTTP_AUTHORIZATION'] = "Bearer #{HaenawaConst::API_TOKEN}"
    scenario = create(:v2_scenario)
    assert_difference(-> {scenario.build_histories.count}, 2) do
      post :create, scenario_id: scenario.id, devices: %w[ie headless_chrome],
           format: :json
    end
    assert_response :success
    assert_template :create
    assert assigns(:created_build_histories)
  end

  def test_登録_json_トークンなし
    scenario = create(:v2_scenario)
    assert_difference(-> {scenario.build_histories.count}, 0) do
      post :create, scenario_id: scenario.id, devices: %w[ie headless_chrome],
           format: :json
    end
    assert_response 401
    assert_equal(ApiAuthentication::INVALID_TOKEN_MESSAGE,
                 response.headers['WWW-Authenticate'])
  end
end
