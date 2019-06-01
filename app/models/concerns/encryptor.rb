module Encryptor
  extend ActiveSupport::Concern

  def decrypt_and_verify(value)
    encryptor.decrypt_and_verify(value)
  end

  def encrypt_and_sign(value)
    encryptor.encrypt_and_sign(value)
  end

  private

  def encryptor
    @_encryptor ||= ::ActiveSupport::MessageEncryptor.new(Rails.application.secrets[:secret_key_base])
  end

end