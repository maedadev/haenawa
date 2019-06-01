ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'webmock/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  include HaenawaConst

  Dir.glob("#{Rails.root}/test/support/*.rb").each do |filename|
    require filename
    if filename.end_with?('_support.rb')
      include File.basename(filename).split('.').first.camelize.constantize
    end
  end

  if Rails.env.test?
    setup do
      FileUtils.rm_rf(CACHE_DIR)
      FileUtils.rm_rf(STORE_BASE_DIR)
    end
  end

  private

  def assert_partial_string_without_indent(expected_string, actual)
    ary = expected_string.split("\n").map {|l| ' *' + Regexp.escape(l) }
    expected_regexp = /^#{ary.join("\n")}/
    assert_match(expected_regexp, actual)
  end
end
