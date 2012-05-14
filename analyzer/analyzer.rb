require 'redis'
require 'bunny'
require 'json'

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

def client
  unless $client
    c = Bunny.new(amqp_url)
    c.start
    $client = c
  end
  $client
end

def trends_exchange
  $nameless_exchange ||= client.exchange('twitter-trends')
end

def messages_queue
  $messages_queue ||= client.queue("tweets")
  $messages_queue.exchange(trends_exchange)
end

puts "Subscribing to message_queue..."
messages_queue.subscribe(:ack => false, :timeout => 10) do |msg|
    puts msg
end
puts "done!"

if (ENV['VCAP_SERVICES'])
  services = JSON.parse(ENV['VCAP_SERVICES'])
  redis_key = services.keys.select { |svc| svc =~ /redis/i }.first
  redis = services[redis_key].first['credentials']
  redis_conf = {:host => redis['hostname'], :port => redis['port'], :password => redis['password']}
  @redis = Redis.new redis_conf
else
  redis_conf = {:host => '127.0.0.1', :port => 6379}
  @redis = Redis.new redis_conf
end


