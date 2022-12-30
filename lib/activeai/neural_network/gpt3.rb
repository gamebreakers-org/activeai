require 'faraday'
require 'faraday/net_http'
require 'faraday/multipart'
Faraday.default_adapter = :net_http

class ActiveAI::NeuralNetwork::GPT3 < ActiveAI::NeuralNetwork

  DEFAULTS = {
    model: 'text-davinci-003',
    temperature: 0.7,
    max_tokens: 1000
  }

  def initialize(token, uuid: 'system', max_tokens: DEFAULTS[:max_tokens], temperature: DEFAULTS[:temperature], model: DEFAULTS[:model])
    @token = token
    @uuid = uuid
    @max_tokens = max_tokens
    @temperature = temperature
    @model = model
  end

  def json_connection
    @json_connection ||= Faraday.new(
      url: 'https://api.openai.com',
      headers: { 'Authorization' => "Bearer #{@token}" }
    ) do |f|
      f.request :json
      f.response :json
    end
  end

  def post(path, params={})
    response = json_connection.post(path, params.merge({ user: @uuid }))
    response.body
  end

  def complete(prompt:, stop: nil, suffix: nil) # TODO move the other stuff besides prompt out?
    post("v1/completions", {
      model: @model,
      prompt: prompt,
      suffix: suffix, # NOTE: doesn't work for fine-tuned models
      stop: stop,
      max_tokens: @max_tokens,
      temperature: @temperature,
      user: @uuid
    })
  end
end
