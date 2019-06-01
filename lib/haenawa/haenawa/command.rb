module Haenawa
  class Command
    include ::Encryptor

    COMMANDS = {
      assertConfirmation: Haenawa::Commands::NilCommand,
      chooseCancelOnNextConfirmation: Haenawa::Commands::NilCommand,
      chooseOkOnNextConfirmation: Haenawa::Commands::NilCommand,
      doubleClick: Haenawa::Commands::NilCommand,
      mouseDown: Haenawa::Commands::NilCommand,
      mouseUp: Haenawa::Commands::NilCommand,
      mouseDownAt: Haenawa::Commands::NilCommand,
      mouseMoveAt: Haenawa::Commands::NilCommand,
      mouseUpAt: Haenawa::Commands::NilCommand,
      mouseOver: Haenawa::Commands::NilCommand,
      mouseOut: Haenawa::Commands::NilCommand,
      select: Haenawa::Commands::NilCommand,
      selectAndWait: Haenawa::Commands::NilCommand,
      webdriverChooseCancelOnVisibleConfirmation: Haenawa::Commands::NilCommand,
      webdriverChooseOkOnVisibleConfirmation: Haenawa::Commands::NilCommand,
      check: Haenawa::Commands::Check,
      uncheck: Haenawa::Commands::Check,
      click: Haenawa::Commands::Click,
      clickAndWait: Haenawa::Commands::Click,
      open: Haenawa::Commands::Open,
      close: Haenawa::Commands::Close,
      pause: Haenawa::Commands::Pause,
      runScript: Haenawa::Commands::RunScript,
      selectFrame: Haenawa::Commands::SelectFrame,
      selectWindow: Haenawa::Commands::Window,
      sendKeys: Haenawa::Commands::SendKeys,
      setWindowSize: Haenawa::Commands::SetWindowSize,
      type: Haenawa::Commands::Type,
      waitForElementPresent: Haenawa::Commands::Wait,
      waitForPopUp: Haenawa::Commands::Wait,
      haenawaRubyEval: Haenawa::Commands::HaenawaRubyEval,
    }.freeze

    COMMAND_NAMES = Command::COMMANDS.keys.map(&:to_s).freeze
    VALID_STRATEGIES = %w(id xpath css link linkText name haenawaLabel).freeze

    class << self
      def create_from_step(step)
        klass = COMMANDS[step.command.to_sym] || Haenawa::Commands::Unsupported
        klass.new(step)
      end
    end

    def initialize(step)
      @step = step
    end

    def options
      @options ||= begin
        options = {}
        prev_command = @step.higher_item&.command
        case prev_command
        when 'chooseOkOnNextConfirmation'
          options[:accept_confirm] = true
        when 'chooseCancelOnNextConfirmation'
          options[:dismiss_confirm] = true
        end
        options
      end
    end

    def command
      @step.command
    end

    def target
      @step.target
    end

    def value
      if @step.encrypted_value.present?
        decrypt_and_verify(@step.encrypted_value)
      else
        @step.value
      end
    end

    def interpolated_value
      I18n.interpolate_hash(value, interpolation_hash)
    end

    def step_no
      @step.step_no
    end

    def validate
      raise NotImplementedError
    end

    def render
      raise NotImplementedError
    end

    def render_unsupported_target
      message = "サポートしていない対象エレメントです。| #{command} | #{target} | #{value} |"
      append_partial("raise \"#{escape_ruby(message)}\"")
    end

    protected

    def interpolation_hash
      @interpolation_hash ||= begin
        steppable = @step.steppable
        build_history = steppable.is_a?(BuildHistory) ? steppable : nil
        scenario = steppable&.scenario
        project = scenario&.project

        {
          build_sequence_code: build_history&.build_sequence_code,
          project_id: project&.id,
          project_name: project&.name,
          scenario_id: scenario&.id,
          scenario_name: scenario&.name,
          scenario_no: scenario&.scenario_no,
          step_id: @step.id,
          step_no: @step.step_no,
          build_history_id: build_history&.id,
          build_history_device: build_history&.device,
        }
      end
    end

    def interpolated_locator
      I18n.interpolate_hash(locator, interpolation_hash)
    end

    def ensure_capture
      ret = []
      ret << ""
      ret << "begin"
      ret += append_partial(yield).split("\n") if block_given?
      ret << "ensure"
      ret << "  $device.save_screenshot(self, :step_no => #{step_no}, :save_dir => ENV['SCREENSHOT_DIR'])"
      ret << "end"
      ret << ""

      append_partial(ret)
    end

    def handle_confirm
      ret = []

      if options[:accept_confirm]
        ret << "accept_confirm do"
        ret << append_partial(yield) if block_given?
        ret << "end"
      elsif options[:dismiss_confirm]
        ret << "dismiss_confirm do"
        ret << append_partial(yield) if block_given?
        ret << "end"
      else
        ret << yield if block_given?
      end

      ret.join("\n")
    end

    def escape_ruby(string)
      string.to_s.gsub('\\', '\\\\').gsub('"', '\"')
    end

    def append_partial(partial)
      ret = []

      if partial
        indent = ' ' * 2

        if partial.is_a?(Array)
          partials = partial
        else
          partials = partial.split("\n")
        end

        partials.each do |line|
          ret << "#{indent}#{line}"
        end
      end

      ret.join("\n")
    end

    def split_target
      case target
      when %r[\A//]
        ['xpath', target]
      when /(.+?)=(.+)/
        [$1, $2]
      else
        [nil, nil]
      end
    end

    def strategy
      split_target.first
    end

    def locator
      split_target.last
    end

    def find_target
      method_name = "find_by_#{strategy.underscore}"
      if !respond_to?(method_name, true)
        raise Haenawa::Exceptions::Unsupported::TargetType
      end
      send(method_name, interpolated_locator)
    end

    def find_by_id(id)
      "first(:id, #{id.dump})"
    end

    def find_by_xpath(xpath)
      # Selenium IDEは `//options[5]` のような、
      # 必ずしも一意に決まらないxpath locatorを生成するが
      # Capybaraのfindメソッドだと一意に決まらなかった場合は
      # Capybara::Ambiguousのエラーを発火するのでここは
      # firstメソッドを使うことにした。
      "first(:xpath, #{xpath.dump})"
    end

    def find_by_css(selector)
      "first(:css, #{selector.dump})"
    end

    def find_by_link(link)
      # linkからexact:プレフィックスを取り除く処理は過去のコードにあった。
      # Selenium IDEのドキュメンターションには見当たらないが、ソースコードには
      # exact:、glob:、regexp:などのlocatorのmatching strategyを決める
      # プレフィックスの付与・参照するコードがあったので、部分的な対応にはなるが
      # 念のため以下のように対応する。
      # 参考:
      # https://github.com/SeleniumHQ/selenium-ide/blob/cad55f1de6645dde2719f245f251f8d4a075b0df/packages/selenium-ide/src/content/targetSelector.js#L20-L31
      # https://github.com/SeleniumHQ/selenium-ide/blob/cad55f1de6645dde2719f245f251f8d4a075b0df/packages/selenium-ide/src/content/PatternMatcher.js#L64-L69
      link = link.sub(/\Aexact:/, '')
      "first(:link, #{link.dump})"
    end

    alias_method :find_by_link_text, :find_by_link

    def find_by_name(name)
      "first(:css, '[name=#{name.dump}]')"
    end

    def find_by_haenawa_label(label)
      "first(:field, #{label.dump})"
    end
  end
end
