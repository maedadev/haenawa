module SetBuildHistories
  private

  def set_build_histories
    build_histories = @scenario.build_histories.order('build_no desc, branch_no')
    @limit_count = build_histories.distinct.select(:build_no).page(params[:page]).per(2)
    @limit_count.total_count(:build_no)
    @build_histories = build_histories.where(build_no: @limit_count.map(&:build_no))
  end
end
