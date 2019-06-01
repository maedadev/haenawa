require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  def test_プロジェクト名は必須
    p = Project.new
    assert p.invalid?
    assert p.errors[:name].any?
  end
end
