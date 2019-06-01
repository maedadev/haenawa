class User
  include ActiveModel::Model

  def my_projects
    @my_projects ||= Project.where(:deleted => false)
  end
end