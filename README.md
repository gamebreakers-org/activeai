# ActiveAI

## AI AS COMPUTE

Artificial Intelligence the Rails way.

Supported by [gamebreakers community](https://gamebreakers.org) - AI is for everyone <3

# Usage

## L0: Interacting directly with neural networks

### GPT3

```
gpt3 = ActiveAI::NeuralNetwork::GPT3.new(ENV['OPEN_AI_TOKEN'])
prompt = "Never gonna give you up, never gonna"
puts gpt3.complete(prompt: prompt)['choices'].first['text']
#=> 'let you down, never gonna run around and hurt you.'
```

### TODO: others

## L1: Using behavior patterns to interact with neural networks

### With structured examples

```
llm = ActiveAI::NeuralNetwork::GPT3.new(ENV['OPEN_AI_TOKEN'], model: 'text-curie-001')
behavior = ActiveAI::Behavior::LLM::FollowStructuredExamples.new(llm, {
  instruction: 'Write a comma-separated list of nouns in the following sentences:',
  examples: [
    { sentence: 'I have some veggie burgers in the freezer!', nouns: 'burgers, freezer' }
    # a couple of examples improves performance!
  ]
})
result = behavior.call({ sentence: 'My tomatoes are in bloom this summer, time for jam!' }, extract: %W[nouns])
puts result
#=> 'tomatoes, jam'
```

### Behavior: WriteFunctionCall

#### TODO

This lets you use `code-davinci-002` or `code-cushman-001` to run logic. The router uses this internally. Supply a list of example pairs that are a "description" and "code", and then you can complete another one.

### TODO: with other patterns

### TODO: auto-detected behavior pattern from config

## L2: Rails magic for neural networks

**This is the fun part!**

Suppose you have the following files:

### config/routes/bank.yml

```
instruction:
  For a given Match request, choose where to send it via the "Route" field and choose the params that fit best.
  If nothing matches, the "Route" field should be None.
examples:
  - Match: Check the weather
    Route: none
  - Match: Send R100 to Jomiro
    Route: bank#transfer_money
    Params: { beneficiaryId: 12345, amount: 100.0 }
  - Match: Pay Mom R245 for groceries
    Route: bank#transfer_money
    Params: { beneficiaryId: 98765, amount: 245.0, reference: "Groceries <3" }
  - Match: What's my bank balance?
    Route: bank#check_balance
```

### controllers/bank_controller.rb

```
class BankController < ActiveAI::Controller
  auto_load_routing # loads routing config from config/routes/bank.yml
  load_routing(config) # alternatively, loads routing config from a hash

  def check_balance
    # Make an API request to GET bank.com/balance and return some useful data
  end

  def transfer_money
    # Make an API request to POST bank.com/transfer with params and return some useful data
  end
end
```

### How to use it

#### Running a controller directly

Using the routing yml file and an LLM, the controller will turn any text request into an action to run, with parameters to supply, and then execute it.

```ruby
controller = BankController.new
controller.call("Pay Mom R127 for groceries")
# => responds with the result of an action that ran with params
```

#### Routing an unknown request with multiple controllers

It's possible to instantiate an `ActiveAI::Router`, load up the examples from multiple controllers, and then have it handle many types of requests. It does this in a similar way to how the controller uses an LLM to map to action and params, but it concatenates all controller routing examples and strips out the parameter preparation step for efficiency, since the controller handles this.

```ruby
router = ActiveAI::Router.new # TODO you need to add providers now.. should be optional?

# load all auto-detected routes:
router.auto_load_routing(Rails.root.join('config','routes')) # loads all .yml files as controller examples

# or, load config via path or manually from a config hash:
router.add_controller_routing_from_path(Rails.root.join("config", "routes", "bank.yml"))
slack_routing = YAML::load(File.read(Rails.root.join("config", "routes", "slack.yml"))
router.add_controller_routing(slack_routing)
```

Once the routes are loaded, requests will be passed to a matched controller, if any matches. You can match and run requests like this:

```ruby
router.call("Send a Slack message saying 'Hey everyone!") # returns the successful action
router.call("Transfer R5,000 to savings") # returns the successful action
router.call("Visit grandma") # returns nil
```

Or if you just want to find the controller:

```ruby
router.find_controller("Transfer money out of savings")
# => BankController
```

# Please help make this better!

This is an experiment to push the boundaries of "AI as compute" and it would be awesome to have more eager explorers to play with!
