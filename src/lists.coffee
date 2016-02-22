# Description
#   A hubot script that allows tracking various items in different lists.
#
# Configuration:
#  < None >
#
# Dependencies:
#   "lodash": "^4.0.0"
#
# Commands:
#   hubot create list <list-name> - create a list of things to tracking
#   hubot add <item> to (the list) <list-name> - add an item to a particular list
#   hubot remove <item> from (the list) <list-name> - remove the specified item from the list
#   hubot lists - show all lists
#   hubot !remove list <list-name> - remove a list and all its entries
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Jacob Smith <jacob.wesley.smith@gmail.com>

_ = require('lodash')

module.exports = (robot) ->
  defaultList = 'default-list'
  normalizeListName = (listName) ->
    if listName == undefined
      return undefined;
    listName.replace(/^ /g, '')

  robot.respond /create list(.*)/i, id: 'lists.create-list', (res) ->
    listName = res.match[1] || defaultList
    listName = normalizeListName(listName)

    currentLists = robot.brain.get('lists') || {}
    if currentLists[listName]
      res.reply "A list already exists with that name."
      return;

    currentLists[listName] = []
    robot.brain.set('lists', currentLists)

    res.reply "I have created a list ('#{listName}')"

  robot.respond /add (.*)to( the list)?(.*)/i, id: 'lists.add-item-to-list', (res) ->
    item = _.trim(res.match[1])
    listName = normalizeListName(res.match[3])
    lists = robot.brain.get('lists') || {}
    list = lists[listName]

    if !list
      res.reply "No list exists with that name. Please double check your spelling."
      return

    list.push(item)

    robot.brain.set('lists', lists)
    res.reply "Added item: '#{item}' to list: '#{listName}'"

  robot.respond /remove (.*)from( the list)?(.*)/i, id: 'lists.remove-item-from-list', (res) ->
    item = _.trim(res.match[1])
    listName = normalizeListName(res.match[3]) || defaultList
    lists = robot.brain.get('lists')
    list = lists[listName] || []
    list = _.remove(list, (itemInList) -> itemInList == item)
    robot.brain.set('lists', lists)
    res.reply "Removed item: '#{item}' from list: '#{listName}'"

  robot.respond /lists/i, id: 'lists.show-all-lists', (res) ->
    lists = _.join(Object.keys(robot.brain.get('lists')), '\n')
    res.reply "Here are the lists I know about: \n#{lists}"

  robot.respond /!remove list (.*)/i, id: 'lists.remove-list', (res) ->
    listName = normalizeListName(res.match[1])
    lists = robot.brain.get('lists')
    if !lists[listName]
      res.reply "No list found with that name. Please double check your spelling."
      return

    delete lists[listName]
    res.reply "Successfully removed the list #{listName}."
