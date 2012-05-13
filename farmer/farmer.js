var stream = require('./lib/twitter-stream-node/lib/stream');

var config = require('./config')

stream.public(username, password, function(tweet) {
    console.log(tweet.text);
});
