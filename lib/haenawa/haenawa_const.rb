module HaenawaConst
  # ファイルシステム関係
  DATA_DIR = "/data/haenawa"
  VAR_DIR = "/var/haenawa"
  DATABASE = YAML.load(ERB.new(File.read('config/database.yml'), 0, '-').result)[Rails.env.to_s]['database']

  CACHE_DIR = File.join(VAR_DIR, DATABASE, 'upload_cache')
  STORE_BASE_DIR  = File.join(DATA_DIR, DATABASE, 'upload_store')

  SELENIUM_DIR = File.join(VAR_DIR, 'selenium')

  # API関係
  salt = 'some one-way function salt'
  API_TOKEN =
    Digest::SHA512.hexdigest(salt + Rails.application.secrets.secret_key_base)
end
