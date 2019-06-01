require 'test_helper'

class StepTest < ActiveSupport::TestCase
  def test_s_new__default_value
    step = Step.new
    assert_equal([], step.targets)
  end

  def test_s_new__set_targets
    step = Step.new(targets: [["css=.btn", "css:finder"]])
    assert_equal([["css=.btn", "css:finder"]], step.targets)
  end

  def test_should_mask?
    s = Step.new(:command => 'type', :target => 'id=password', :value => 'test')
    assert s.should_mask?
    assert_equal '********', s.masked_value
  end

  def test_create_command_assert_confirmation
    step = Step.new(command: 'assertConfirmation')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_choose_ok_on_next_confirmation
    step = Step.new(command: 'chooseOkOnNextConfirmation')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_choose_cancel_on_next_confirmation
    step = Step.new(command: 'chooseCancelOnNextConfirmation')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_double_click
    step = Step.new(command: 'doubleClick')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_mouse_out
    step = Step.new(command: 'mouseOut')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_mouse_over
    step = Step.new(command: 'mouseOver')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_mouse_down_at
    step = Step.new(command: 'mouseDownAt')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_mouse_move_at
    step = Step.new(command: 'mouseMoveAt')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_mouse_up_at
    step = Step.new(command: 'mouseUpAt')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_webdriver_choose_ok_on_visible_confirmation
    step = Step.new(command: 'webdriverChooseOkOnVisibleConfirmation')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_create_command_webdriver_choose_cancel_on_visible_confirmation
    step = Step.new(command: 'webdriverChooseCancelOnVisibleConfirmation')
    command = step.step_command
    assert_instance_of(Haenawa::Commands::NilCommand, command)
  end

  def test_to_side_file_content
    step = Step.new(command: 'click',
                    comment: '「新しいプロジェクトを追加」をクリック',
                    target: 'linkText=新しいプロジェクトを追加',
                    targets: [
                      ['linkText=新しいプロジェクトを追加', 'linkText'],
                      ['css=.btn', 'css:finder'],
                    ],
                    value: '')
    result = step.to_side_file_content
    assert_match(UUID_PATTERN, result[:id])
    assert_equal('「新しいプロジェクトを追加」をクリック', result[:comment])
    assert_equal('click', result[:command])
    assert_equal('linkText=新しいプロジェクトを追加', result[:target])
    assert_equal([
                   ['linkText=新しいプロジェクトを追加', 'linkText'],
                   ['css=.btn', 'css:finder'],
                 ], result[:targets])
    assert_equal('', result[:value])
    assert_equal(6, result.length)
  end

  private

  # https://github.com/wilmoore/uuid-regexp.js/blob/v0.3.0/regexp.js#L14 を
  # 参考に「\Aその正規表現\z」とした。
  UUID_PATTERN =
    /\A[a-f0-9]{8}-?[a-f0-9]{4}-?[1-5][a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}\z/i
end
