module Haenawa
  module Commands
    class Pause < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        else
          begin
            Float(target)
          rescue ArgumentError, TypeError
            @step.errors.add(:target, :invalid)
          end
        end
      end

      def render
        sec = (target.to_f / 1000).ceil
        ensure_capture do
          partial = []
          partial << "sleep #{sec}"
        end
      end
    end
  end
end
