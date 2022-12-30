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

## L1: Using behavior patterns to interact with underlying neural networks

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

### TODO: with other patterns

### TODO: auto-detected behavior pattern from config

## L2: Rails adapters

This is the fun part!

### controller.rb

```
class MyBank < ActiveAI::Controller
  def check_balance
    # Make an API request to GET bank.com/balance
  end

  def transfer_money
    # Make an API request to POST bank.com/transfer with params
  end
end
```

### routes.yml

```
instruction:
  For a given Match request, choose where to send it via the "To" field and choose the params that fit best.
  If nothing matches, the "To" field should be None.
examples:
  - Match: Check the weather
    To: none
  - Match: Send R100 to Jomiro
    To: bank#transfer_money
    Params: { beneficiaryId: 12345, amount: 100.0 }
  - Match: Pay Mom R245 for groceries
    To: bank#transfer_money
    Params: { beneficiaryId: 98765, amount: 245.0, reference: "Groceries <3" }
  - Match: What's my bank balance?
    To: bank#check_balance
```
