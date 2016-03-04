github_user = process.env.HUBOT_GITHUB_USER = "test_user"
github_repo = process.env.HUBOT_GITHUB_REPO = "test_repo"

chai = require 'chai'
sinon = require 'sinon'
Helper = require 'hubot-test-helper'
PullRequestParser = require '../src/pull_request_parser'

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

  beforeEach ->
    room.message = []
    @robot = room.robot

  afterEach ->
    room.destroy()

  # describe 'list open pull requests', ->
  #   it 'lists all open PRs', (done) ->
  #     room.user.say 'alice', '@hubot list open pull requests'

  describe 'link accounts', ->
    it 'links github and hubot accounts', (done) ->
      room.user.say 'alice', '@hubot i am alice_github on github'
      waitForReplies 2, room, ->
        expect(lastMessageContent(room)).to.equal("@alice Successfully connected alice to github user alice_github")
        expect(room.robot.brain.get("github-assignments.github-name.alice_github")).to.equal('@alice')
        expect(room.robot.brain.get("github-assignments.chat-name.@alice")).to.equal('alice_github')
        done()

  describe 'PullRequestParser', ->
    pullRequestParser = null

    beforeEach ->
      pullRequestParser = new PullRequestParser(room)

    fakeJsonResponse = {
      number: 123,
      assignee: {
        login: 'johndoe'
      },
      title: 'PR Title',
      user: {
        login: 'janedoe'
      },
      _links: {
        html: {
          href: 'githubpullrequest.com'
        }
      }
    }

    it "parses a JSON response", (done) ->
      response = pullRequestParser.get_opts(fakeJsonResponse)
      expect(response).to.eql(
        {
          number: 123,
          assignee: 'johndoe',
          title: 'PR Title',
          author: 'janedoe',
          link: 'githubpullrequest.com'
        }
      )
      done()

    it "substitutes assignee and author for chat names if present in robot.brain", (done) ->
      room.robot.brain.set('github-assignments.johndoe', '@jdog')
      room.robot.brain.set('github-assignments.janedoe', '@jane_dog')
      response = pullRequestParser.get_opts(fakeJsonResponse)
      expect(response).to.eql(
        {
          number: 123,
          assignee: '@jdog',
          title: 'PR Title',
          author: '@jane_dog',
          link: 'githubpullrequest.com'
        }
      )
      done()
