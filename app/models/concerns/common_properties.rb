module CommonProperties
  extend ActiveSupport::Concern

  def destroy_logically
    self.deleted = true
    save
  end

  def destroy_logically!
    self.deleted = true
    save!
  end

  def created_at_string
    return nil unless self.created_at
    self.created_at.to_s(:datetime)
  end

  def updated_at_string
    return nil unless self.updated_at
    self.updated_at.to_s(:datetime)
  end

  module ClassMethods

    def not_deleted
      where(:deleted => false)
    end

  end
end