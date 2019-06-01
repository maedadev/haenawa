FactoryBot.define do
  factory :build_history do
    association(:scenario, factory: :v2_scenario)

    build_no { 1 }
    branch_no { 1 }
    device { 'ie' }
    result { 0 }
    build_sequence_code { 42 }
  end
end
