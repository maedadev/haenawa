module Haenawa
  module Commands
    class Check < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
          return
        elsif !VALID_STRATEGIES.include?(strategy) || locator.blank?
          @step.errors.add(:target, :invalid)
        else
          begin
            interpolated_locator
          rescue I18n::MissingInterpolationArgument
            @step.errors.add(:target, :invalid_placeholder)
          end
        end
      end

      def render
        ensure_capture do
          handle_confirm do
            "#{find_target}.set(#{command == 'check'})"
          end
        end
      rescue Haenawa::Exceptions::Unsupported::TargetType
        render_unsupported_target
      end
    end
  end
end
