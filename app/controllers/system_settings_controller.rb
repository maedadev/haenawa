class SystemSettingsController < ApplicationController
  include HaenawaConst

  def show
    @system_setting = SystemSetting.first
    redirect_to :action => 'new' unless @system_setting.present?
  end

  def grid
    unless SystemSetting.first.selenium_host.present?
      render :nothing => true and return
    end

    begin
      conn = Faraday.new(:url => "http://#{SystemSetting.first.selenium_host}:4444") do |faraday|
       faraday.request :url_encoded
       faraday.adapter Faraday.default_adapter
      end

      response = conn.get('/grid/console')
      @nodes = Nokogiri::HTML(response.body).css('div.proxy')
      render :partial => 'grid'
    rescue => e
      @message = e.message
      render :partial => 'hub_connection_error'
    end
  end

  def download_node
    send_file File.join(SELENIUM_DIR, 'selenium-2.53.zip')
  end

  def new
    @system_setting = SystemSetting.new
  end

  def create
    @system_setting = SystemSetting.new(system_setting_params)
    
    @system_setting.transaction do
      @system_setting.save_and_generate_node!
    end
    
    redirect_to @system_setting
  end
  
  def edit
    @system_setting = SystemSetting.first
  end

  def update
    @system_setting = SystemSetting.first
    @system_setting.attributes = system_setting_params
    
    @system_setting.transaction do
      @system_setting.save_and_generate_node!
    end
    
    redirect_to :action => 'show'
  end

  private

  def system_setting_params
    permitted = [:selenium_host]
    
    ret = params.require(:system_setting)

    case action_name
    when 'create', 'update'
      ret = ret.permit(*permitted)
    end
    
    ret
  end
end
