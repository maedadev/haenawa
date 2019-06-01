module Haenawa
  module Commands
    class SendKeys < Command
      VALID_KEYS = [
        '${KEY_ENTER}'
      ]
      
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        elsif !VALID_STRATEGIES.include?(strategy) || locator.blank?
          @step.errors.add(:target, :invalid)
        end

        if value.blank?
          @step.errors.add(:value, :missing)
        elsif !VALID_KEYS.include?(key)
          @step.errors.add(:value, :invalid)
        end
      end

      def key
        case value
        when /\${KEY_([A-Z]+).*}/
          ':' + $1.downcase
        else
          value
        end
      end
      
      def render
        ensure_capture do
          "#{find_target}.send_keys(#{key})"
        end
      rescue Haenawa::Exceptions::Unsupported::TargetType
        render_unsupported_target
      end
    end
  end
end
