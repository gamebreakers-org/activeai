class ActiveAI::Behavior
  def self.from_config(config)
    # TODO detect and load the right pattern
    # right now it's just "structuredexamples"
    # this is just syntactic sugar, it's fine for now until you _need_ it
  end
end

require_relative "behavior/base"
