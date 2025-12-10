# frozen_string_literal: true

module Falcon
  module Watch
    commit_path = File.expand_path("../../../.commit", __dir__)

    if File.readable? commit_path
      commit = File.read commit_path
      VERSION = "0.1.0-#{commit}"
    else
      VERSION = "0.1.0"
    end
  end
end
