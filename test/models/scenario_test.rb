require 'test_helper'

class ScenarioTest < ActiveSupport::TestCase

  def test_changed?
    assert ! scenario.changed?
    
    scenario.build_histories.build
    assert ! scenario.changed?
  end

  def test_シナリオ名は必須
    s = Scenario.new(file: "example.html")
    assert s.invalid?
    assert s.errors[:name].any?
  end

  def test_ファイル選択は必須
    s = Scenario.new(name: "test_scenario")
    assert s.invalid?
    assert s.errors[:file].any?
  end

  def test_app_host
    s = Scenario.new(
      file: File.new('test/data/maeda.html'),
      original_filename: "maeda.html",
      content_type: "text/html"    
    )
    assert_equal s.app_host,"www.maeda.co.jp"
  end

  def test_app_port
    s = Scenario.new( 
      file: File.new('test/data/maeda.html'),
      original_filename: "maeda.html",
      content_type: "text/html"    
    )
    assert_equal s.app_port,"80"
  end

  def test_feature_file
    s = Scenario.new(
      file: File.new('test/data/maeda.html'),
      original_filename: "maeda.html",
      content_type: "text/html",
      id: "1",
      project_id: "1"
    )
    assert_match(%r{/data/haenawa/.*/upload_store/1/features/scenario_1.feature},s.feature_file)
  end

  def test_result_dir
    s = Scenario.new(
      file: File.new('test/data/maeda.html'),
      original_filename: "maeda.html",
      content_type: "text/html",
      id: "1",
      project_id: "1"
    )
    assert_match(%r{/data/haenawa/.*/upload_store/1/test/scenario_1},s.test_result_dir)
  end

  def test_to_side_file_content
    scenario = create(:v2_scenario)
    scenario.steps.build(step_no: 1,
                         command: 'click',
                         target: 'linkText=新しいプロジェクトを追加',
                         targets: [
                           ['linkText=新しいプロジェクトを追加', 'linkText'],
                           ['css=.btn', 'css:finder'],
                         ],
                         value: '')
    scenario.steps.build(step_no: 2,
                         command: 'type',
                         target: 'id=scenario_name',
                         targets: [
                           ['id=scenario_name', 'id'],
                           ['name=scenario[name]', 'name'],
                         ],
                         value: 'test')
    result = scenario.to_side_file_content
    # .sideファイルに必要なキーが含まれている確認
    assert_equal(%i[id version name url tests suites urls plugins].sort,
                 result.keys.sort)
    # 個々の内容はStepTest#test_to_side_file_contentで試験しているため、
    # ここではstep_no順にコマンドが入っている確認のみ行う。
    assert_equal(%w[click type],
                 result[:tests][0][:commands].map {|c| c[:command] })
  end
end
