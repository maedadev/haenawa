require 'test_helper'

class SendKeysTest < ActiveSupport::TestCase

  def test_send_keys
    step = Step.new(step_no: 1, command: 'sendKeys', target: 'css=.botui-actions-text-input', value: '${KEY_ENTER}')
    partial = step.step_command.render

    assert_partial_string_without_indent(<<EOS, partial)
first(:css, ".botui-actions-text-input").send_keys(:enter)
EOS
  end

end
