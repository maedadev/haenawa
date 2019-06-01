if Rails.env.development?
  NON_BUSINESS_MODELS = %w(
    ActiveRecord::SchemaMigration
  )

  Rake::Task['db:migrate'].enhance do
    ENV['exclude'] = NON_BUSINESS_MODELS.join(',')
    ENV['filename'] = 'tmp/ER図'
    ENV['attributes'] = 'foreign_key, content, inheritance'
    ENV['inheritance'] = 'true'
    Rake::Task['erd'].invoke
  end
end
