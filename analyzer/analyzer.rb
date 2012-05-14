require 'redis'

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

