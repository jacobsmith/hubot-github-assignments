github_user = process.env.HUBOT_GITHUB_USER = "test_user"
github_repo = process.env.HUBOT_GITHUB_REPO = "test_repo"

chai = require 'chai'
sinon = require 'sinon'
Helper = require 'hubot-test-helper'

chai.use require 'sinon-chai'

expect = chai.expect

helper = new Helper('../index.coffee')

waitForReplies = (number, room, callback) ->
  setTimeout(->
    if room && room.messages.length >= number
      callback(room)
    else
      waitForReplies(number, room, callback)
  )

lastMessageContent = (room) ->
  room.messages[room.messages.length - 1][1]

describe 'github', ->
  room = helper.createRoom();
  github_user = null
  github_repo = null

  beforeEach ->
    room.message = []

    @robot = room.robot

  afterEach ->
    room.destroy()

  describe 'list open pull requests', ->
    it 'lists all open PRs', (done) ->
      room.user.say 'alice', '@hubot list open pull requests'
