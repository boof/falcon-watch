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
      handler = ->(*) do
        ctrl.restart
      rescue StandardError => e
        warn e.message
      end

      notifier = INotify::Notifier.new
      %w[config.ru Gemfile.lock].each do |path|
        notifier.watch(File.join(root, path), :modify, &handler)
      end

      ctrl.start
      notifier.run
    rescue Interrupt, SystemExit
      # stop server gracefully
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

      def start
        @controller.start
      end

      def restart
        @controller.restart
      end

      def stop
        @controller.stop
      end
    end
  end

  def self.watch(...) = Watch.start(...)
end
