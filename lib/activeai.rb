# frozen_string_literal: true

require_relative "activeai/behavior"
require_relative "activeai/configuration"
require_relative "activeai/controller"
require_relative "activeai/neural_network"
require_relative "activeai/router"
require_relative "activeai/version"

module ActiveAI
  class Error < StandardError; end
  
  def self.config
    {
      gpt3_token: ENV['OPEN_AI_TOKEN']
    }
  end

end

