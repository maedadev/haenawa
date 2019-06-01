FactoryBot.define do
  factory :scenario do
    project
    name { 'Test Scenario' }

    factory :v1_scenario do
      file do
        Rack::Test::UploadedFile.new(Rails.root / 'test/data/maeda.html',
                                     'text/html')
      end
    end

    factory :v2_scenario do
      file do
        Rack::Test::UploadedFile.new(Rails.root / 'test/data/haenawa.side', '')
      end
    end
  end
end
