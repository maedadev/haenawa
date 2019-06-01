class SystemSetting < ActiveRecord::Base

  def save_and_generate_node!
    save!
    JobUtils.add_job(GenerateSeleniumNodeJob)
  end

end
