module Haenawa
  module Commands
    class SetWindowSize < Command
      def validate
        case target
        when ''
          @step.errors.add(:target, :missing)
        when /\A\d+x\d+/
        else
          @step.errors.add(:target, :invalid)
        end
      end

      def render
        width, height = *target.split('x', 2).map(&:to_i)
        ensure_capture do
          <<-EOF
$device.resize_window(#{width}, #{height})
          EOF
        end
      end
    end
  end
end
