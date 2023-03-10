class ActiveAI::Behavior::LLM < ActiveAI::Behavior::Base
  def initialize(llm)
    @llm = llm
  end
  
  def complete(prompt, stop: nil)
    @llm.complete(prompt: prompt, stop: stop)
  end

  LINE_SEPARATOR = "\n\n###\n\n"

  def extract_keys(completion, extract)
    matcher_string = extract.map{ |key| "#{key}:(.*)" }.join
    matches = completion.match(/#{matcher_string}/m)

    if matches
      matches[1..-1].map.with_index do |value, index|
        # TODO this seems hacky, gotta be a better way to extract?
        [extract[index], value.strip]
      end.to_h
    else
      nil
    end
  end
end

require_relative "llm/conversation"
require_relative "llm/follow_structured_examples"
require_relative "llm/unstructured"
require_relative "llm/write_function_call"