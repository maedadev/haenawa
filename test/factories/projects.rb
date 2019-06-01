FactoryBot.define do
  factory :project do
    name { 'Test Project' }
    default_build_sequence_code { 'forty-two'}
  end
end
