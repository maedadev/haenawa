class BuildHistoryReporter < ActionView::Base

  def initialize(instance_variables = {})
    view_paths = [
      File.join(Rails.root, 'app', 'views')
    ]

    super(view_paths, instance_variables)
  end

  def pdf_image_path(path)
    "file://#{path}"
  end

  def render_text
    text = render(:template => 'build_histories/report', :layout => false)

    File.binwrite(File.join('tmp', "build_#{@build_history.build_no}.txt"), text) unless Rails.env.production?
    
    text
  end
end
