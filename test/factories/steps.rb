FactoryBot.define do
  factory :step do

    step_no { 1 }
    target { '' }
    value { '' }
    comment { '' }

    trait :for_v2_scenario do
      steppable { |s| s.association(:v2_scenario) }
    end

    trait :for_build_history do
      steppable { |s| s.association(:build_history) }
    end
  end
end
