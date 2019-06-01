class Project < ActiveRecord::Base
  validates :name, :presence => true

  has_many :scenarios, -> {where(deleted: false).order(:scenario_no)}

  def masked_redmine_api_key
    if redmine_api_key.present?
      '*' * 32
    else
      nil
    end
  end

  def build_dir
    File.join(STORE_BASE_DIR, id.to_s)
  end

  def feature_dir
    File.join(build_dir, 'features')
  end

  def support_dir
    File.join(feature_dir, 'support')
  end

  def save_and_generate_support_env!
    save!
    JobUtils.add_job(GenerateSupportEnvJob, :project_id => id)
  end

end
