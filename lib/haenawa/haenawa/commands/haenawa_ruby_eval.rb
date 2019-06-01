module Haenawa
  module Commands
    class HaenawaRubyEval < Command
      def validate
        if value.blank?
          @step.errors.add(:value, :missing)
        else
          begin
            interpolated_value
          rescue I18n::MissingInterpolationArgument
            @step.errors.add(:value, :invalid_placeholder)
          end
        end
      end

      def render
        ensure_capture do
          interpolated_value
        end
      end
    end
  end
end
