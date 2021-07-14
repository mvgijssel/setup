# frozen_string_literal: true

require 'async'
require 'async/process'

module Async
  module IO
    class Generic
      def read_line
        line = String.new('')

        loop do
          character = read(1)

          return if character.nil?

          line << character

          break if character == "\n"
        end

        line
      end
    end
  end
end

module Async
  module Process
    class Child
			private

			def wait_thread
				@input.read(1)

			ensure
				# If the user stops this task, we kill the process:
				if @exit_status.nil?
          clean_kill
				end

				@thread.join

				# We are done with the notification pipe:
				@input.close
				@output.close
			end

      def clean_kill
        puts "Clean killing #{@pid}"
        ::Process.kill(:INT, @pid)

        loop do
          break unless process_running?(@pid)
        end

        puts "Properly killed #{@pid}"
      end

      # Copied from https://github.com/wilsonsilva/process_exists/blob/master/lib/process_exists/core_ext/process.rb
      def process_running?(pid)
        ::Process.kill(0, pid.to_i)
        true
      rescue Errno::ESRCH # No such process
        false
      rescue Errno::EPERM # The process exists, but you dont have permission to send the signal to it.
        true
      end
    end
  end
end

module RSpec
  module ServerHelpers
    module Helpers
      def run(command, timeout:, extra_env: {})
        Async do |process_wrapper_task|
          read_io, write_io = Async::IO.pipe
          stdout_string = String.new('')

          logger_task = Async do
            loop do
              line = read_io.read_line
              break if line.nil?
              stdout_string << line
              puts line
            end
          end

          begin
            process_wrapper_task.with_timeout(timeout) do
              # Get the environment before applying bundler
              # note we can also do Bundler.clean_env to remove bundler variables from the env
              environment = Bundler.original_env.merge(extra_env)
              environment.stringify_keys!

              puts "Starting process: #{command}"

              result = Async::Process.spawn(
                environment,
                command,
                out: write_io,
                err: %i[child out],
                unsetenv_others: true
              )
              write_io.close
              Result.new(result.exitstatus, stdout_string)
            end
          rescue Async::TimeoutError => e
            write_io.close
            Result.new(nil, stdout_string, e)
          rescue Async::Wrapper::Cancelled => e
            write_io.close
            Result.new(nil, stdout_string, e)
          ensure
            logger_task.stop
          end
        end
      end

      def wait_for_ssh(host, timeout:)
        total_attempts = (timeout / (2 + 1)).floor
        current_attempt = 1

        Async do |wait_task|
          wait_task.with_timeout(timeout) do
            loop do
              result = ssh('true', host, timeout: 2).wait

              if result.success?
                break
              else
                puts "[#{current_attempt}/#{total_attempts}] SSH failed, retrying in 1s..."
                wait_task.sleep(1)
                current_attempt += 1
              end
            end
          end
        end.wait
      end

      def ssh(command, host, timeout:)
        id_rsa_path = "#{ENV.fetch('SETUP_SCRIPTS_DIR')}/keys/id_rsa"
        ssh_command = "ssh debian@#{host} -i #{id_rsa_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{command}"

        run(ssh_command, timeout: timeout)
      end
    end
  end
end
