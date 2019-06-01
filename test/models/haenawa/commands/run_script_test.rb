require 'test_helper'

class RunScriptTest < ActiveSupport::TestCase
  def test_run_script
    step = Step.new(step_no: 1, command: 'runScript', target:  'console.log(\'foo\\\'bar"baz\quux#{hoge}hogehoge\')', value: '')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<'EOS', partial)
evaluate_script("console.log('foo\\'bar\"baz\\quux\#{hoge}hogehoge')")
EOS
  end

  def test_validate_target_allow_script
    script =<<SCRIPT
function greet(name) {
  console.alert('Hello ' + name + '!');
}
end
greet('World');
SCRIPT
    step = Step.new(step_no: 1, command: 'runScript', target: script, value: '')
    step.step_command.validate
    assert(step.errors.blank?)
  end

  def test_validate_target_do_not_allow_blank
    step = Step.new(step_no: 1, command: 'runScript', target: '', value: '')
    step.step_command.validate
    expected = %w(対象エレメントの指定は必須です。対象エレメントの指定例をご参考ください。)
    assert_equal(expected, step.errors.full_messages)
  end
end
