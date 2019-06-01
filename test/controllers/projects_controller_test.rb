require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  def setup
    projects = {
      :projects => [
        {:id => 1, :name => '延縄プロジェクト', :identifier => 'haenawa'}
      ]
    }
    stub_request(:get, /.*redmine.example.com.*/).to_return(:body => projects.to_json, :headers => {'Content-Type' => 'application/json'})
  end

  def test_一覧
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    get :show, :id => create(:project).id
    assert_response :success
    assert_template :show
    assert assigns(:project)
  end

  def test_参照_json
    scenario = create(:v2_scenario)
    project = create(:project, scenarios: [scenario])
    get :show, id: project.id, format: 'json'
    assert_response :success
    assert_template :show
    assert assigns(:project)
    expected = {
      id: project.id,
      name: project.name,
      scenarios: [
        {
          id: scenario.id,
          name: scenario.name,
        },
      ]
    }
    assert_equal(expected, JSON.parse(@response.body, symbolize_names: true))
  end

  def test_追加
    get :new
    assert_response :success
    assert_template :new
    assert assigns(:project)
  end

  def test_登録
    post :create, :project => project_params
    assert_response :redirect
    assert_redirected_to assigns(:project)
  end

  def test_登録_入力エラー
    post :create, :project => project_params.merge(:name => '')
    assert_response :success
    assert_template :new
    assert @project = assigns(:project)
    assert @project.errors[:name].any?
  end

  def test_編集
    get :edit, :id => project.id
    assert_response :success
    assert_template :edit
    assert assigns(:project)
  end

  def test_更新
    patch :update, :id => project.id, :project => project_params.merge(:lock_version => project.lock_version)
    assert_response :redirect
    assert_redirected_to project
  end

  def test_更新_入力エラー
    patch :update, :id => project.id, :project => project_params.merge(:name => '')
    assert_response :success
    assert_template :edit
    assert @project = assigns(:project)
    assert @project.errors[:name].any?
  end

  def test_更新_楽観ロック
    patch :update, :id => project.id, :project => project_params.merge(:lock_version => project.lock_version - 1)
    assert_response :success
    assert_template :edit
    assert @project = assigns(:project)
    assert @project.errors[:base].include?(I18n.t('error.messages.stale'))
  end

  def test_削除
    delete :destroy, :id => project.id
    assert_response :redirect
    assert_redirected_to action: :index
  end
end
