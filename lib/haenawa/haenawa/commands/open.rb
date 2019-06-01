module Haenawa
  module Commands
    class Open < Command
      def validate
        if target.blank?
          @step.errors.add(:target, :missing)
        else
          begin
            URI.parse(target)
          rescue URI::InvalidURIError
            @step.errors.add(:target, :invalid)
          end
        end
      end

      def render
        ensure_capture do
          partial = []
          partial << "visit '#{target}'"
          partial << "assert has_selector?('body')"
        end
      end
    end
  end
end
