module Haenawa
  module Commands
    class Wait < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        elsif '_blank' == target
        elsif !VALID_STRATEGIES.include?(strategy) || locator.blank?
          @step.errors.add(:target, :invalid)
        else
          begin
            interpolated_locator
          rescue I18n::MissingInterpolationArgument
            @step.errors.add(:target, :invalid_placeholder)
          end
        end

        if value.present?
          begin
            Float(value)
          rescue ArgumentError, TypeError
            @step.errors.add(:value, :invalid)
          end
        end
      end

      def render
        ensure_capture do
          if target.include?('_blank') || value.present?
            sec = (value.to_f / 1000).ceil
            "sleep #{sec}"
          else
            "#{find_target}"
          end
        end
      rescue Haenawa::Exceptions::Unsupported::TargetType
        render_unsupported_target
      end
    end
  end
end
