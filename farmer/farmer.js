var amqp = require('amqp');
var htmlEscape = require('sanitizer/sanitizer').escape;

var stream = require('./lib/twitter-stream-node/lib/stream');

var config = require('./config');

function rabbitUrl() {
  if (process.env.VCAP_SERVICES) {
    conf = JSON.parse(process.env.VCAP_SERVICES);
    return conf['rabbitmq-2.4'][0].credentials.url;
  }
  else {
    return "amqp://localhost";
  }
}

function setup() {

  var exchange = conn.exchange('twitter-farmer', {'type': 'fanout', durable: false}, function() {

    var queue = conn.queue('', {durable: false, exclusive: true},
    function() {
      queue.subscribe(function(msg) {
        console.log(msg);
      });
      queue.bind(exchange.name, '');
    });
    queue.on('queueBindOk', function() { gatherTweets(exchange); });
  });
}

function gatherTweets(exchange) {
	stream.public(config["username"], config["password"], function(tweet) {
	    console.log(tweet.text);
		exchange.publish('', {body: tweet.text});
	});
}

var conn = amqp.createConnection({url: rabbitUrl()});
conn.on('ready', setup);


