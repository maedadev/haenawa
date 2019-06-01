require 'test_helper'

class ScenariosControllerTest < ActionController::TestCase
  def setup
    @scenario = create(:v2_scenario)
  end

  def test_参照
    get :show, id: @scenario.id
    assert_response :success
    assert_template :show
  end

  def test_参照_side
    get :show, id: @scenario.id, format: :side
    assert_response :success
    assert_equal('application/json', @response.content_type)
    assert_equal(%Q'attachment; filename="#{@scenario.original_filename}"',
                 @response.header["Content-Disposition"])
  end

  def test_追加
    get :new, project_id: @scenario.project.id
    assert_response :success
    assert_template :new
    assert assigns(:scenario)
  end

  def test_登録
    post :create, scenario: attributes_for(:v2_scenario), project_id: @scenario.project.id
    assert_response :redirect
    assert_redirected_to assigns(:scenario)
  end

   def test_登録_入力エラー
    post :create, scenario: attributes_for(:v2_scenario).merge(name: ''), project_id: @scenario.project.id
    assert_response :success
    assert_template :new
    scenario = assigns(:scenario)
    assert scenario
    assert_not_equal [], scenario.errors[:name]
    assert_equal 1, scenario.errors.count
  end

  def test_編集
    get :edit, id: @scenario.id
    assert_response :success
    assert_template :edit
    assert assigns(:scenario)
  end

  def test_更新
    patch :update, id: @scenario.id, scenario: {name: "シナリオ2" } #scenario_params.merge(:lock_version => scenario.lock_version)
    assert_response :redirect
    assert_redirected_to @scenario
  end

  def test_更新_入力エラー
    patch :update, id: @scenario.id, scenario: {name: ""}
    assert_response :success
    assert_template :edit
    scenario = assigns(:scenario)
    assert scenario
    assert_not_equal [], scenario.errors[:name]
    assert_equal 1, scenario.errors.count
  end

  def test_削除
    delete :destroy, id: @scenario.id
    assert_response :redirect
    assert_redirected_to @scenario.project
  end

  def test_シナリオの順序変更_上へ
    project = create(:project)
    scenario_a, scenario_b, scenario_c = *create_list(:v2_scenario, 3, project: project)
    patch :move_up, id: scenario_b
    assert_response :redirect
    expected = [
      [scenario_b.id, 1],
      [scenario_a.id, 2],
      [scenario_c.id, 3],
    ]
    assert_equal(expected, project.scenarios.pluck(:id, :scenario_no))
    assert_redirected_to project
  end

  def test_シナリオの順序変更_下へ
    project = create(:project)
    scenario_a, scenario_b, scenario_c = *create_list(:v2_scenario, 3, project: project)
    patch :move_down, id: scenario_b
    assert_response :redirect
    expected = [
      [scenario_a.id, 1],
      [scenario_c.id, 2],
      [scenario_b.id, 3],
    ]
    assert_equal(expected, project.scenarios.pluck(:id, :scenario_no))
    assert_redirected_to project
  end
end
