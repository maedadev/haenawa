class ScenarioUploader < CarrierWave::Uploader::Base
  include HaenawaConst

  storage :file
  process :set_metadata

  def cache_dir
    CACHE_DIR
  end

  def store_dir
    "#{STORE_BASE_DIR}/#{model.project_id}/scenarios"
  end

  def extension_white_list
    %w(html)
  end

  def filename
    return super unless file.present?
    HaenawaUtils.hashed_filename(file)
  end

  private

  def set_metadata
    if file.present?
      self.model.content_type = file.content_type
      self.model.original_filename = file.original_filename
    end
  end

end
