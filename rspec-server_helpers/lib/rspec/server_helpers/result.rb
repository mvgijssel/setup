module RSpec
  module ServerHelpers
    class Result
      attr_reader :exitstatus
      attr_reader :error
      attr_reader :stdout

      def initialize(exitstatus, stdout, error = nil)
        @exitstatus = exitstatus
        @stdout = stdout
        @error = error
      end

      def success?
        !exitstatus.nil? && exitstatus.zero?
      end
    end
  end
end
