gulp          = require 'gulp'
Twitter       = require 'twitter'
{ Readable }  = require 'stream'
through       = require 'through2'
async         = require 'async'

config  = require 'config-object'
config.load 'config.cson', required: yes

twitter = new Twitter config.get 'twitter'
gulp.task 'default', ->
  endpoint  = 'statuses/user_timeline'
  params    =
    screen_name : 'lazurski'
    trim_user   : yes

  stream = new Readable objectMode: yes
  stream._read = ->
    # https://nodejs.org/api/stream.html#stream_readable_read_size_1
    # http://stackoverflow.com/a/22085851/1151982

  twitter.get endpoint, params, (error, tweets, res) ->
    async.eachSeries tweets,
      (tweet, done) ->
        stream.push tweet
        do done
      (error) ->
        if error then return stream.emit 'error', error
        stream.push null


  stream
    .pipe through.obj (tweet, encoding, done) ->
      console.log tweet.text
      do done
