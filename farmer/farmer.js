var stream = require('twitter-stream');
stream.public(username, password, function(tweet) {
    console.log(tweet.text);
});
