ActiveSupport.on_load :active_record do
  include HaenawaConst
  include CommonProperties
end

ActiveSupport.on_load :action_view do
  module ActionView::CompiledTemplates
    include HaenawaConst
  end
end
