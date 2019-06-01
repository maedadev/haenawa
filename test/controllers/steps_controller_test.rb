require 'test_helper'

class StepsControllerTest < ActionController::TestCase
  def setup
    @scenario = create(:v2_scenario)
  end

  def test_一覧
    xhr :get, :index, scenario_id: @scenario.id
    assert_response :success
    assert_template :index
    assert assigns(:scenario)
  end

  def test_参照_png
    bh = @scenario.build_histories.create!(build_no: 1)
    step = bh.steps.create!(step_no: 1, command: 'click', target: 'css=body')
    FileUtils.touch(bh.screenshot_path_for(step.step_no))
    get :show, id: step.id
    assert_response :success
    assert_equal(%Q'inline; filename="img-#{bh.id}-#{'%02d' % step.step_no}.png"',
                 @response.header["Content-Disposition"])
  end

  def test_登録
    assert_difference(-> {@scenario.steps.count}, 1) do
      xhr :post, :create, scenario_id: @scenario.id, step_no: 1
    end
    assert_response :success
    assert_template :index
    assert assigns(:scenario)
  end

  def test_削除
    step = @scenario.steps.create!(step_no: 1,
                                   command: 'click', target: 'css=body')
    assert_difference(-> {@scenario.steps.count}, -1) do
      xhr :delete, :destroy, id: step.id
    end
    assert_response :success
    assert_template :index
    assert assigns(:scenario)
  end

  def test_削除_未知のコマンド
    step = @scenario.steps.create!(step_no: 1,
                                   command: 'click', target: 'css=body')
    step.command = 'notExistCommand'
    step.save(validate: false)
    assert_difference(-> {@scenario.steps.count}, -1) do
      xhr :delete, :destroy, id: step.id
    end
    assert_response :success
    assert_template :index
    assert assigns(:scenario)
  end
end
