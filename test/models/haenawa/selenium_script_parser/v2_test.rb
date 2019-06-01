require 'test_helper'

class V2Test < ActiveSupport::TestCase
  def test_s_processable__return_true_if_v2_file
    scenario = build(:v2_scenario)
    assert_equal(true,
                 Haenawa::SeleniumScriptParser::V2.processable?(scenario.file))
  end

  def test_s_processable__return_false_if_v1_file
    scenario = build(:v1_scenario)
    assert_equal(false,
                 Haenawa::SeleniumScriptParser::V2.processable?(scenario.file))
  end

  def test_base_url
    parsed = Haenawa::SeleniumScriptParser::V2.new(build(:v2_scenario).file)
    assert_equal('http://localhost:3000', parsed.base_url)
  end

  def test_each_step
    parsed = Haenawa::SeleniumScriptParser::V2.new(build(:v2_scenario).file)
    assert_equal([
                   {comment: '', command: 'open', target: '/projects', value: '', targets: []},
                   {comment: '', command: 'setWindowSize', target: '831x695', value: '', targets: []},
                   {
                     comment: '「新しいプロジェクトを追加」をクリック',
                     command: 'click',
                     target: 'linkText=新しいプロジェクトを追加',
                     value: '',
                     targets: [
                       ["linkText=新しいプロジェクトを追加", "linkText"],
                       ["css=.btn", "css:finder"],
                       ["xpath=//a[contains(text(),'新しいプロジェクトを追加')]", "xpath:link"],
                       ["xpath=//a[contains(@href, '/projects/new')]", "xpath:href"],
                       ["xpath=//div/a", "xpath:position"],
                     ]
                   },
                   {
                     comment: 'プロジェクト名のクリック',
                     command: 'click',
                     target: 'id=project_name',
                     value: '',
                     targets: [
                       ["id=project_name", "id"],
                       ["name=project[name]", "name"],
                       ["css=#project_name", "css"],
                       ["css=#project_name", "css:finder"],
                       ["xpath=//input[@id='project_name']", "xpath:attributes"],
                       ["xpath=//form[@id='new_project']/div/input", "xpath:idRelative"],
                       ["xpath=//div/input", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'click',
                     target: 'name=commit',
                     value: '',
                     targets: [
                       ["name=commit", "name"],
                       ["css=input[name=\"commit\"]", "css"],
                       ["css=.btn-primary", "css:finder"],
                       ["xpath=//input[@name='commit']", "xpath:attributes"],
                       ["xpath=//form[@id='new_project']/div[3]/input", "xpath:idRelative"],
                       ["xpath=//form/div[3]/input", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'click',
                     target: 'linkText=新しいシナリオを追加',
                     value: '',
                     targets: [
                       ["linkText=新しいシナリオを追加", "linkText"],
                       ["css=.btn:nth-child(1)", "css:finder"],
                       ["xpath=//a[contains(text(),'新しいシナリオを追加')]", "xpath:link"],
                       ["xpath=//a[contains(@href, '/14/scenarios/new')]", "xpath:href"],
                       ["xpath=//div[2]/a", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'click',
                     target: 'id=scenario_name',
                     value: '',
                     targets: [
                       ["id=scenario_name", "id"],
                       ["name=scenario[name]", "name"],
                       ["css=#scenario_name", "css"],
                       ["css=#scenario_name", "css:finder"],
                       ["xpath=//input[@id='scenario_name']", "xpath:attributes"],
                       ["xpath=//form[@id='new_scenario']/div/input", "xpath:idRelative"],
                       ["xpath=//div/input", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'type',
                     target: 'id=scenario_name',
                     value: 'test',
                     targets: [
                       ["id=scenario_name", "id"],
                       ["name=scenario[name]", "name"],
                       ["css=#scenario_name", "css"],
                       ["css=#scenario_name", "css:finder"],
                       ["xpath=//input[@id='scenario_name']", "xpath:attributes"],
                       ["xpath=//form[@id='new_scenario']/div/input", "xpath:idRelative"],
                       ["xpath=//div/input", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'click',
                     target: 'name=commit',
                     value: '',
                     targets: [
                       ["name=commit", "name"],
                       ["css=input[name=\"commit\"]", "css"],
                       ["css=.btn-primary", "css:finder"],
                       ["xpath=//input[@name='commit']", "xpath:attributes"],
                       ["xpath=//form[@id='new_scenario']/div[3]/input", "xpath:idRelative"],
                       ["xpath=//div[3]/input", "xpath:position"],
                     ],
                   },
                   {
                     comment: '',
                     command: 'type',
                     target: 'id=project_name',
                     value: 'haenawa-test',
                     targets: [
                       ["id=project_name", "id"],
                       ["name=project[name]", "name"],
                       ["css=#project_name", "css"],
                       ["css=#project_name", "css:finder"],
                       ["xpath=//input[@id='project_name']", "xpath:attributes"],
                       ["xpath=//form[@id='new_project']/div/input", "xpath:idRelative"],
                       ["xpath=//div/input", "xpath:position"],
                     ]
                   },
                 ], parsed.to_enum(:each_step).to_a)
  end
end
