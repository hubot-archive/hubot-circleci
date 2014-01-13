# Description:
#   Get status and control CircleCI from hubot
#
# Dependencies:
#   None
#
# Commands:
#   hubot circle me <user>/<repo> [branch] - Returns the build status of https://circleci.com/<user>/<repo>
#   hubot circle last <user>/<repo> [branch] - Returns the build status of the last complete build of https://circleci.com/<user>/<repo>
#   hubot circle retry <user>/<repo> <build_num> - Retries the build
#   hubot circle cancel <user>/<repo> <build_num> - Cancels the build
#   hubot circle clear <user>/<repo> - Clears the cache for the specified repo
#
# Configuration:
#   Set HUBOT_CIRCLECI_TOKEN with a valid API Token from CircleCI.
#   You can add an API token at https://circleci.com/account/api
#
# URLS:
#   POST /hubot/circle?room=<room>[&type=<type>]
#
# Author:
#   dylanlingelbach

url = require('url')
util = require('util')
querystring = require('querystring')

endpoint = 'https://circleci.com/api/v1'

toSha = (vcs_revision) ->
  vcs_revision.substring(0,7)

toDisplay = (status) ->
  status[0].toUpperCase() + status.slice(1)

formatBuildStatus = (build) ->
  "#{toDisplay(build.status)} in build #{build.build_num} of #{build.vcs_url} [#{build.branch}/#{toSha(build.vcs_revision)}] #{build.committer_name}: #{build.subject} - #{build.why}"

checkToken = (msg) ->
  unless process.env.HUBOT_CIRCLECI_TOKEN?
    msg.send 'You need to set HUBOT_CIRCLECI_TOKEN to a valid CircleCI API token'
    return false
  else
    return true

handleResponse = (msg, handler) ->
  (err, res, body) ->
    if err?
      msg.send "Something went really wrong: #{err}"

    switch res.statusCode
      when 404
        response = JSON.parse(body)
        msg.send "I couldn't find what you were looking for: #{response.message}"
      when 401
        msg.send 'Not authorized.  Did you set HUBOT_CIRCLECI_TOKEN correctly?'
      when 500
        msg.send 'Yikes!  I turned that circle into a square' # Don't send body since we'll get HTML back from Circle
      when 200
        response = JSON.parse(body)
        handler response
      else
        msg.send "Hmm.  I don't know how to process that CircleCI response: #{res.statusCode}", body

module.exports = (robot) ->
  
  robot.respond /circle me (\S*)\s*(\S*)/i, (msg) ->
    unless checkToken(msg)
      return
    project = escape(msg.match[1])
    branch = if msg.match[2] then escape(msg.match[2]) else 'master'
    msg.http("#{endpoint}/project/#{project}/tree/#{branch}?circle-token=#{process.env.HUBOT_CIRCLECI_TOKEN}")
      .headers("Accept": "application/json")
      .get() handleResponse  msg, (response) ->
          if response.length == 0
            msg.send "Current status: #{project} [#{branch}]: unknown"
          else
            currentBuild = response[0]
            msg.send "Current status: #{formatBuildStatus(currentBuild)}"

  robot.respond /circle last (\S*)\s*(\S*)/i, (msg) ->
    unless checkToken(msg)
      return
    project = escape(msg.match[1])
    branch = if msg.match[2] then escape(msg.match[2]) else 'master'
    msg.http("#{endpoint}/project/#{project}/tree/#{branch}?circle-token=#{process.env.HUBOT_CIRCLECI_TOKEN}")
      .headers("Accept": "application/json")
      .get() handleResponse msg, (response) ->
          if response.length == 0
            msg.send "Current status: #{project} [#{branch}]: unknown"
          else
            last = response[0]
            if last.status != 'running'
              msg.send "Current status: #{formatBuildStatus(last)}"
            else if last.previous && last.previous.status
              msg.send "Last status: #{formatBuildStatus(last)}"
            else
              msg.send "Last build status for #{project} [#{branch}]: unknown"

  robot.respond /circle retry (.*) (.*)/i, (msg) ->
    unless checkToken(msg)
      return
    project = escape(msg.match[1])
    
    unless msg.match[2]?
      msg.send "I can't retry without a build number"
      return
    build_num = escape(msg.match[2])
    msg.http("#{endpoint}/project/#{project}/#{build_num}/retry?circle-token=#{process.env.HUBOT_CIRCLECI_TOKEN}")
      .headers("Accept": "application/json")
      .post('{}') handleResponse msg, (response) ->
          msg.send "Retrying build #{build_num} of #{project} [#{response.branch}] with build #{response.build_num}"

  robot.respond /circle cancel (.*) (.*)/i, (msg) ->
    unless checkToken(msg)
      return
    project = escape(msg.match[1])
    unless msg.match[2]?
      msg.send "I can't cancel without a build number"
      return
    build_num = escape(msg.match[2])
    msg.http("#{endpoint}/project/#{project}/#{build_num}/cancel?circle-token=#{process.env.HUBOT_CIRCLECI_TOKEN}")
      .headers("Accept": "application/json")
      .post('{}') handleResponse msg, (response) ->
          msg.send "Canceled build #{response.build_num} for #{project} [#{response.branch}]"

  robot.respond /circle clear (.*)/i, (msg) ->
    unless checkToken(msg)
      return
    project = escape(msg.match[1])
    msg.http("#{endpoint}/project/#{project}/build-cache?circle-token=#{process.env.HUBOT_CIRCLECI_TOKEN}")
      .headers("Accept": "application/json")
      .del('{}') handleResponse msg, (response) ->
          msg.send "Cleared build cache for #{project}"

  robot.router.post "/hubot/circle", (req, res) ->
    query = querystring.parse url.parse(req.url).query
    res.end JSON.stringify {
       received: true #some client have problems with an empty response
    }

    user = {}
    user.room = query.room if query.room
    user.type = query.type if query.type

    try
      robot.send user, formatBuildStatus(req.body.payload)

    catch error
      console.log "circle hook error: #{error}. Payload: #{util.inspect(req.body.payload)}"

