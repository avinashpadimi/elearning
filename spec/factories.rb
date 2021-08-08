FactoryBot.define do 
  factory :coach do 
    name { "mystring" }
  end

  factory :course do 
    name { "mystring" }
    self_assignable { true }
    association :coach, factory: :coach
  end
end
