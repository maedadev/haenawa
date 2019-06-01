module BuildHistoriesSupport

  def build_history
    if @_build_history.nil?
      assert @_build_history = BuildHistory.first
    end
    @_build_history
  end
end

