# 31 December 2022

## What I did

- Fix active_ai/controller.rb to reflect on the correct detected path name
- Ran a full test with thinkspawn creating DALLE art and sending Slack messages - it's really cool!
- Released v0.1.1!!

## What I learned

- Gonna need a master router and make the sub-routers just about param prep
- Curie doesn't do great with routing many controllers. I had to rename e.g. slack.notify to slack.send_message because that seemed to be Curie's default.. DaVinci works better but also some issues i think

## What I could do next

- add whisper as a neural network via replicate.com
- add embeddings as a concept - not sure what/how yet
- make better examples for routing, it's a bit iffy right now
- add a better way in code to test controllers test cases etc.
- test out if the code models work better than the text ones

# 30 December 2022

## What I did

- Built a basic gem!
- Added behaviors, specifically for structured trained examples
- Added rails controllers and routers which use structured trained examples
- Added a cool prototype conversation/chat structure, and a cool idea on how to make operators ponder!

## What I learned

- I need to learn more about modules, classes and gem structuring
- Rails Engines is going to be a thing, probably, maybe
- ActiveAI is a boring name. How about something that's more expansive, welcoming, inclusive, social?

## What I could do next

- Run a real example via thinkspawn and get it all working
- Make active_ai/behavior.rb#from_config with a sensible default behavior and test a few others
- Make the code work like the readme says it does for rails stuff (controller naming and folder structure etc.) - might need a Railtie?
- Publish v0.1.1
- Update the configuration.rb mechanic a bit
- Load up all OpenAI's examples as instances of one of a couple of behavior types
- Add session contexts to the router registration so it's flexible
