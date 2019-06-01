require 'test_helper'

class SeleniumScriptParserTest < ActiveSupport::TestCase
  def setup
    @saved_parsers = Haenawa::SeleniumScriptParser.parsers
  end

  def teardown
    Haenawa::SeleniumScriptParser.parsers = @saved_parsers
  end

  def test_s_run__return_processable_parser
    scenario = build(:v2_scenario)
    assert_instance_of(Haenawa::SeleniumScriptParser::V2,
                       Haenawa::SeleniumScriptParser.run(scenario.file))
  end

  def test_s_run__return_nil_if_all_parsers_are_not_processable
    Haenawa::SeleniumScriptParser.parsers = []
    scenario = build(:v2_scenario)
    assert_nil(Haenawa::SeleniumScriptParser.run(scenario.file))
  end
end
