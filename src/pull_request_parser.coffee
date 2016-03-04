_ = require('lodash')

class PullRequestParser
  constructor: (robot) ->
    this.robot = robot

  get_opts: (pr) ->
    number = pr.number
    assignee = robot.brain.get("github-assignments." + _.get(pr, "assignee.login")) || _.get(pr, "assignee.login") || 'no one'
    title = pr.title
    author = robot.brain.get("github-assignments.#{pr.user.login}") || pr.user.login
    link = pr._links.html.href
    {
      number: number,
      assignee: assignee,
      title: title,
      author: author,
      link: link
    }

module.exports = PullRequestParser
