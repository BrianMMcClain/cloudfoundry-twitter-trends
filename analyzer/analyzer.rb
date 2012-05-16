require 'redis'
require 'bunny'
require 'json'
require 'uuid'

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
uuid = UUID.new
queue_name = "tweet-analyzer-#{uuid.generate(:compact)}"
q = b.queue(queue_name)
q.bind(exch)

puts "Subscribing to #{queue_name}"
q.subscribe do |msg|
    puts msg[:payload]
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


