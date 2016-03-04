# Description
#   List pull request assignments
#
# Configuration:
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_REPO
#   HUBOT_GITHUB_API_TOKEN
#   The above need set as ENV vars.
#
# Dependencies:
#   "lodash": "^4.0.0"
#   "github4": "latest"
#
# Commands:
#  hubot list open pull requests
#  hubot pull requests assigned to <github_username>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Jacob Smith <jacob.wesley.smith@gmail.com>

_ = require('lodash')
PullRequestParser = require './pull_request_parser'

GitHubApi = require('github4')
github = new GitHubApi({
    version: "3.0.0",
    debug: true,
    protocol: "https",
    host: "api.github.com", #// should be api.github.com for GitHub
    pathPrefix: "", #// for some GHEs; none for GitHub
    timeout: 5000
});
github.authenticate({
  type: 'token'
  token: "#{process.env.HUBOT_GITHUB_API_TOKEN}"
})
github_user = "#{process.env.HUBOT_GITHUB_USER}"
github_repo = "#{process.env.HUBOT_GITHUB_REPO}"


overview_text = (opts) ->
  "#{opts.author}'s [PR #{opts.number} - #{opts.title}](#{opts.link}) is assigned to #{opts.assignee}"

assigned_to_user = (opts, user) ->
  "#{opts.author}'s [PR ##{opts.number} - #{opts.title}](#{opts.link}) is assigned to #{user}."

module.exports = (robot) ->
  pullRequestParser = new PullRequestParser(robot)

  robot.respond /(list)?\s?(open|all( open)?)?\s?(pull requests|prs)$/i, id: 'github.list-open-pull-requests', (res) ->
    github.pullRequests.getAll({ user: github_user, repo: github_repo}, (err, github_response) ->
      pullRequests = github_response
      pullRequestResponse = []
      _.each(pullRequests, (pr) -> pullRequestResponse.push(overview_text(pullRequestParser.get_opts(pr))))
      res.reply _.join(_.map(pullRequestResponse, (i) -> "\n - #{i}"), "")
    )

  robot.respond /(prs|pull requests)\s?(assigned to|for)\s?(.*)/i, id: 'github.pull-requests-assigned-to-user', (res) ->
    user = res.match[1].toLowerCase()
    if user == "me"
      user = "@#{res.message.user.name.toLowerCase()}"

    if robot.brain.get("github-assignments.chat-name.#{user}")
      user = robot.brain.get("github-assignments.chat-name.#{user}")

    github.pullRequests.getAll({ user: github_user, repo: github_repo}, (err, pullRequests) ->
      pullRequestResponse = []
      _.each(pullRequests, (pr) ->
        opts = pullRequestParser.get_opts(pr)
        if opts.assignee == user
          pullRequestResponse.push(
            assigned_to_user(parse_pr(pr), user)
          )
      )
      if pullRequestResponse.length > 0
        res.reply _.join(_.map(pullRequestResponse, (i) -> "\n - #{i}"), "")
      else
        res.reply "There are no pull requests currently assigned to: #{user}"
    )

  robot.respond /i am (.*) on github/i, id: 'github.self-identify', (res) ->
    githubUserName = res.match[1]
    robot.brain.set("github-assignments.github-name.#{githubUserName}", "@#{res.message.user.name}")
    robot.brain.set("github-assignments.chat-name.#{"@" + res.message.user.name.toLowerCase()}", "#{githubUserName}")
    res.reply "Successfully connected #{res.message.user.name} to github user #{githubUserName}"
