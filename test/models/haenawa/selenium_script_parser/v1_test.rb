require 'test_helper'

class V1Test < ActiveSupport::TestCase
  def test_s_processable__return_true_if_v1_file
    scenario = build(:v1_scenario)
    assert_equal(true,
                 Haenawa::SeleniumScriptParser::V1.processable?(scenario.file))
  end

  def test_s_processable__return_false_if_v2_file
    scenario = build(:v2_scenario)
    assert_equal(false,
                 Haenawa::SeleniumScriptParser::V1.processable?(scenario.file))
  end

  def test_base_url
    parsed = Haenawa::SeleniumScriptParser::V1.new(build(:v1_scenario).file)
    assert_equal('http://www.maeda.co.jp', parsed.base_url)
  end

  def test_each_step
    parsed = Haenawa::SeleniumScriptParser::V1.new(build(:v1_scenario).file)
    assert_equal([
                   {command: 'open', target: '/', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=サービス＆ソリューション', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=実績紹介', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=技術紹介', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=企業情報', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=IR情報', value: '', targets: []},
                   {command: 'clickAndWait', target: 'link=CSR', value: '', targets: []},
                 ], parsed.to_enum(:each_step).to_a)
  end
end
