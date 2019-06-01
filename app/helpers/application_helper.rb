module ApplicationHelper
  def render_error_messages(target)
    render :partial => 'common/error_messages', :locals => {:target => target}
  end

  def title_attr_from_comment(record)
    comment = record.comment
    if comment.present?
      " title=#{comment}"
    end
  end
end
