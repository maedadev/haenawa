class CreateStepsJob
  @queue = :normal

  def self.perform(options = {})
    ActiveRecord::Base.clear_active_connections! unless Rails.env.test?
    options = HashWithIndifferentAccess.new(options)

    @scenario = Scenario.find(options[:scenario_id])

    Rails.logger.info "Seleniumテストからステップを作成します。#{options}"

    @scenario.transaction do
      @scenario.steps.map{|s| s.deleted = true }

      @scenario.parsed_file.to_enum(:each_step).with_index do |step, i|
        s = @scenario.steps.build(:step_no => i + 1)
        s.comment = step[:comment]
        s.command = step[:command]
        s.target = step[:target]
        s.targets = step[:targets]

        if s.should_mask?
          s.encrypted_value = s.encrypt_and_sign(step[:value])
        else
          s.value = step[:value]
        end

      end

      # Stepレコードのバリデーションエラーはユーザが読み込み後に
      # HaenawaのUI上で直す想定なのでこの段階ではバリデーションを実行しない。
      # Scenarioレコードのバリデーションはcreateアクションで実行される。
      @scenario.save(validate: false)
    end

    Rails.logger.info "Seleniumテストからステップを作成しました。#{options}"
  end

  SELECTOR_TYPES = %w[linkText xpath:link xpath:position]

end
