# frozen_string_literal: true

require_relative "lib/falcon/watch/version"

Gem::Specification.new do |spec|
  spec.name = "falcon-watch"
  spec.version = Falcon::Watch::VERSION
  spec.authors = ["Florian Aßmann"]
  spec.email = ["florian.assmann@email.de"]

  spec.summary = "Starts and restarts a Socketry's HTTP server Falcon on config change."
  spec.description = <<~MARKDOWN
# falcon-watch

This simple gem just starts a falcon server and restarts it when config.ru or
gem dependencies change.

Similar to guard-falcon but with less pitfalls.

Pitfalls:

The guard plugin breaks as soon as guard restarts due to a config change since
the previous falcon instances isn't shut down correctly.

Also it's hard to tell guard to handle unreadable subdirectories which breaks
guard when run with a local postgresql instance that isn't run as unprivileged
user (eg. when using the official postgresql docker image).
This is a unresolved, inactive issue with rb-inotify (a guard dependency).
  MARKDOWN
  spec.homepage = "https://github.com/boof/falcon-watch"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/boof/falcon-watch"
  spec.metadata["changelog_uri"] = "https://github.com/boof/falcon-watch/CHANGELOD.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rb-inotify", "~> 0.11.1"
  spec.add_dependency "falcon", "~> 0.53"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
