module Steppable
  extend ActiveSupport::Concern

  included do
    has_many :steps, -> {where(:deleted => false).order(step_no: :asc)}, :as => :steppable, :inverse_of => 'steppable'
    accepts_nested_attributes_for :steps
  end

  def step_at(step_no)
    steps.find{|s| s.step_no.to_i == step_no.to_i}
  end
end
