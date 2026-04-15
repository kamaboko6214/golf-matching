FactoryBot.define do
  factory :participation do
    user
    recruitment
    status { :pending }
  end
end
