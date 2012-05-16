require 'tweetstream'
require "json"

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
end