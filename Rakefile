# frozen_string_literal: true

task :"dump-commit" do
  __git__ = File.join __dir__, ".git"

  head = File.read File.join(__git__, "HEAD")
  ref = head[%r{^ref: refs/(.+)$}, 1]
  commit = File.read File.join(__git__, "refs", ref)

  File.write File.join(__dir__, ".commit"), commit.chomp
end

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
