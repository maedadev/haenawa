module Haenawa
  module Commands
    class Click < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
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
            "#{find_target}.click"
          end
        end
      rescue Haenawa::Exceptions::Unsupported::TargetType
        render_unsupported_target
      end
    end
  end
end
