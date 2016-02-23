chai = require 'chai'
sinon = require 'sinon'
Helper = require('hubot-test-helper')

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

describe 'lists', ->
  room = helper.createRoom();

  beforeEach ->
    room.message = []

    @robot = room.robot

  afterEach ->
    room.destroy()

  describe 'registered listeners', ->
    # it 'registers a create list listener', ->
    #   expect(@robot.respond).to.have.been.calledWith(/create list/i)
    # it 'registers an add item to list listener', ->
    #   expect(@robot.respond).to.have.been.calledWith(/add (.*) to (the list)(.*)/i)
    #
    # it 'registers a remove item to list listener', ->
    #   expect(@robot.respond).to.have.been.calledWith(/remove (.*) from (the list)(.*)/i)
    #
    # it 'registers a show lists listener', ->
    #   expect(@robot.respond).to.have.been.calledWith(/lists/i)
    #
    # it 'registers a remove lists listener', ->
    #   expect(@robot.respond).to.have.been.calledWith(/remove list (.*)/i)

  describe 'create list', ->
    beforeEach ->
      room.robot.brain.set('lists', undefined)

    it 'creates a default list when called with no list-name argument', (done) ->
      room.user.say 'alice', '@hubot create list'
      waitForReplies 1, room, ->
        expect(lastMessageContent(room)).to.eql "@alice I have created a list ('default-list')"
        expect(room.robot.brain.get('lists')).to.eql({ 'default-list': [] })
        done()

    it 'creates a list with a name if given one', (done) ->
      room.user.say 'alice', '@hubot create list retro-items'
      waitForReplies 1, room, ->
        expect(lastMessageContent(room)).to.eql "@alice I have created a list ('retro-items')"
        expect(room.robot.brain.get('lists')).eql({ 'retro-items': [] })
        done()

    it 'does not create a list of the same name if one already exists', (done) ->
      room.robot.brain.set('lists', { 'test-list': [] })
      room.user.say 'alice', '@hubot create list test-list'
      waitForReplies 1, room, ->
        expect(lastMessageContent(room)).to.eql "@alice A list already exists with that name."
        expect(room.robot.brain.get('lists')).to.eql( { 'test-list': [] })
        done()


  describe 'lists', ->
    it 'delineates all lists', (done) ->
      @robot.brain.set 'lists', { 'Test List': [], 'Test List 2': [] }
      room.user.say 'alice', '@hubot lists'
      waitForReplies 1, room, ->
        expect(lastMessageContent(room)).to.eql '@alice Here are the lists I know about: \nTest List\nTest List 2'
        done()

  describe 'adding items to lists', ->
    it 'adds the item if the list exists', (done) ->
      @robot.brain.set 'lists', 'test-list': []
      room.user.say 'alice', '@hubot add a new item to test-list'
      waitForReplies 1, room, ->
        expect(room.robot.brain.get('lists')['test-list']).to.eql([ 'a new item' ])
        done()

    it 'adds the item if the list exists with additional verbiage', (done) ->
      @robot.brain.set 'lists', 'test-list': []
      room.user.say 'alice', '@hubot add a second new item to the list test-list'
      waitForReplies 1, room, ->
        expect(room.robot.brain.get('lists')['test-list']).to.eql([ 'a second new item' ])
        done()

  describe "removing items from a list", ->
    it "removes the item from the list", (done) ->
      @robot.brain.set 'lists', 'test-list': ['foo', 'bar']
      room.user.say 'alice', '@hubot remove foo from test-list'
      waitForReplies 1, room, ->
        expect(room.robot.brain.get('lists')['test-list']).to.eql(['bar'])
        done()

    it "removes the item from the list with additional verbiage", (done) ->
      @robot.brain.set 'lists', 'test-list': ['foo', 'bar']
      room.user.say 'alice', '@hubot remove foo from the list test-list'
      waitForReplies 1, room, ->
        expect(room.robot.brain.get('lists')['test-list']).to.eql(['bar'])
        done()

  describe "removing a whole list", ->
    it "removes the entire list", (done) ->
      @robot.brain.set 'lists', 'test-list': []
      room.user.say 'alice', '@hubot !remove list test-list'
      waitForReplies 1, room, ->
        expect(room.robot.brain.get('lists')['test-list']).to.eql(undefined)
        done()

  describe "show contents of a list", ->
    it "shows all of the contents of that list", (done) ->
      @robot.brain.set 'lists', 'test-list': ['foo', 'bar', 'baz']
      room.user.say 'alice', '@hubot show list test-list'
      waitForReplies 1, room, ->
        expect(lastMessageContent(room)).to.eql "@alice Here are the contents of test-list:\n - foo\n - bar\n - baz"
        done()
