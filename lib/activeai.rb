# frozen_string_literal: true

module ActiveAI
  class Error < StandardError; end
  
  def self.config
    {
      gpt3_token: ENV['OPEN_AI_TOKEN']
    }
  end

  def self.route_examples_to_function_call_examples(examples)
    examples.map do |example|
      function = example['Route'].gsub('/','.').gsub('#','.')
      function = "unmatched" if function == "None"
      
      {
        description: example['Match'],
        code: "#{function}(#{example['Params']&.strip})"
      }
    end
  end

end

require_relative "activeai/behavior"
require_relative "activeai/configuration"
require_relative "activeai/controller"
require_relative "activeai/neural_network"
require_relative "activeai/router"
require_relative "activeai/version"
