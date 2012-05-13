var stream = require('./lib/twitter-stream-node/lib/stream');

var config = require('./config');

stream.public(config["username"], config["password"], function(tweet) {
    console.log(tweet.text);
});
