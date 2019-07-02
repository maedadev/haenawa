require 'bizside/redmine/client'

module RedmineAware
  extend ActiveSupport::Concern

  included do
    validates :redmine_host, :presence => true, :if => :use_redmine?
    validates :redmine_api_key, :presence => true, :if => :use_redmine?
    validates :redmine_identifier, :presence => true, :if => :use_redmine?
    validate :verify_redmine_configuration
  end

  def redmine_project
    ret = nil
    3.times do |i|
      ret = redmine.projects(page: i+1, per: 100).find{|p| p['identifier'] == redmine_identifier }
      break if ret
    end
    ret
  end

  def redmine_project_url
    "https://#{redmine_host}/redmine/projects/#{redmine_identifier}"
  end

  private

  def redmine
    @redmine ||= Bizside::Redmine::Client.new(redmine_configuration)
  end

  def verify_redmine_configuration
    return unless use_redmine?
    return unless (errors[:redmine_host] + errors[:redmine_api_key] + errors[:redmine_identifier]).empty?

    begin
      unless redmine_project
        errors[:base] << I18n.t('errors.messages.redmine_project_not_found', :identifier => redmine_identifier)
      end
    rescue => e
      Rails.logger.warn e.message
      errors[:base] << I18n.t('errors.messages.invalid_redmine_configuration')
    end
  end

  def redmine_configuration
    {
      :host => redmine_host,
      :api_key => redmine_api_key,
      :verify_ssl => false,
      :prefix => '/redmine'
    }
  end

end
