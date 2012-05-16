require 'tweetstream'
require 'json'
require 'bunny'

def amqp_url
  if (ENV["VCAP_SERVICES"])
    services = JSON.parse(ENV['VCAP_SERVICES'], :symbolize_names => true)
    url = services.values.map do |srvs|
      srvs.map do |srv|
        if srv[:label] =~ /^rabbitmq-/
          srv[:credentials][:url]
        else
          []
        end
      end
    end.flatten!.first
  else
    return "amqp://localhost"
  end
end

# Setup AMQP Messaging
b = Bunny.new
b.start
#exch = b.exchange('tweets').delete
exch = b.exchange('tweets', :type => :fanout)

# Read in the config file
configJson = File.read('config.json')
appconfig = JSON.parse(configJson)

TweetStream.configure do |config|
  config.consumer_key = appconfig["consumer_key"]
  config.consumer_secret = appconfig["consumer_secret"]
  config.oauth_token = appconfig["access_token"]
  config.oauth_token_secret = appconfig["access_secret"]
  config.auth_method = :oauth
  config.parser   = :json_pure
end

TweetStream::Client.new.sample do |status|
  puts "#{status.text}"
  # Publish the tweet to the queue
  exch.publish(status.text)
end