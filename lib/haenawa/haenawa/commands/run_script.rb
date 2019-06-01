module Haenawa
  module Commands
    class RunScript < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        end
      end

      def render
        ensure_capture do
          partial = []
          partial << "evaluate_script(#{target.dump})"
        end
      end
    end
  end
end
