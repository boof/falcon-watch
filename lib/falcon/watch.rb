# frozen_string_literal: true

require "async/service"
require "rb-inotify"

require "falcon"
require "falcon/endpoint"
require "falcon/environment/rackup"
require "falcon/environment/server"

module Falcon
  module Watch
    autoload :VERSION, File.join("watch/version", __dir__)

    class Error < StandardError; end

    def self.start(...)
      root = Dir.pwd
      raise "File `config.ru' couldn't be found.`" unless File.readable? File.join(root, "config.ru")

      ctrl = Controller.new(...)
      restart = ctrl.method(&:restart)

      notifier = INotify::Notifier.new
      %w[config.ru Gemfile.lock].each do |path|
        notifier.watch(File.join(root, path), :modify, restart)
      end

      ctrl.start
      notifier.run
    ensure
      ctrl.stop if ctrl&.running?
    end

    class Controller
      module Environment
        include ::Falcon::Environment::Server
        include ::Falcon::Environment::Rackup

        def endpoint
          ::Falcon::Endpoint.parse(url).with(reuse_address: true, timeout: timeout)
        end
      end

      def self.default_environment(**)
        Async::Service::Environment.new(Environment).with(**)
      end

      def self.info(*methods)
        type = self.name
        methods.each do |method|
          m = instance_method method
          define_method(method) do |*args, **opts, &block|
            time = Time.now
            from = caller_locations(1,1)[0].label

            message = format("@%<time>s %<pid>i ::%<type>s#%<method>s(%<arguments>p) from %<from>s",
              time: time.iso8601, pid: Process.pid, type:, method:, arguments: [args, opts, block], from:)
            puts message

            m.bind_call self, *args, **opts, &block
          end
        end
      end

      def initialize(**options)
        options[:root] ||= Dir.pwd
        options[:name] ||= "falcon"

        if paths = options[:paths]
          @configuration = Async::Service::Configuration.load(paths)
        else
          @configuration = Async::Service::Configuration.new
          @configuration.add self.class.default_environment(**options)
        end

        @controller = ::Async::Service::Controller.new @configuration.services.to_a
      end

      def running? = @controller.running?

      info def start
        @controller.start
      end

      info def restart
        @controller.restart
      end

      info def stop
        @controller.stop
      end
    end
  end

  def self.watch(...) = Watch.start(...)
end
