module StepsHelper
  def description_div(command, type, visible)
    description = begin
      key = "views.steps.edit.descriptions.#{type}.#{command}"
      default_key = 'views.steps.edit.descriptions.unsupported_command'
      I18n.t(key, default: default_key).html_safe
    end

    explanation = begin
      key = "views.steps.edit.explanations.#{type}.#{command}"
      I18n.t(key, default: '').html_safe
    end

    attrs = {
      id: "#{command}-#{type}-description",
      class: 'description'
    }

    if !visible
      attrs[:style] = 'display:none;'
    end

    explanation_id = "#{command}-#{type}-explanation"

    explanation_toggle = if explanation.blank?
      ''
    else
      toggle_text = I18n.t('views.steps.edit.toggle_explanation')
      content_tag(:a, toggle_text, data: { toggle: 'collapse' }, href: "##{explanation_id}")
    end

    explanation_div = if explanation.blank?
      ''
    else
      content_tag(:div, explanation, id: explanation_id, class: 'well collapse')
    end

    description_span = content_tag(:span, description)

    content_tag(:div, attrs) do
      content_tag(:p, description_span + explanation_toggle) + explanation_div
    end
  end
end
