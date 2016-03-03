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


parse_pr = (pr) ->
  number = pr.number
  assignee = _.get(pr, 'assignee.login') || 'no one'
  title = pr.title
  author = pr.user.login
  link = pr._links.html.href
  {
    number: number,
    assignee: assignee,
    title: title,
    author: author,
    link: link
  }

overview_text = (opts) ->
  "#{opts.author}'s PR ##{opts.number} (#{opts.title}) is assigned to #{opts.assignee} (#{opts.link})'"

assigned_to_user = (opts, user) ->
  "#{opts.author}'s PR ##{opts.number} (#{opts.link}) is assigned to #{user}."


module.exports = (robot) ->

  robot.respond /list open pull requests/i, id: 'github.list-open-pull-requests', (res) ->
    github.pullRequests.getAll({ user: github_user, repo: github_repo}, (err, github_response) ->
      pullRequests = github_response
      pullRequestResponse = []
      _.each(pullRequests, (pr) -> pullRequestResponse.push(overview_text(parse_pr(pr))))
      res.reply _.join(_.map(pullRequestResponse, (i) -> "\n - #{i}"), "")
    )

  robot.respond /pull requests assigned to (.*)/i, id: 'github.pull-requests-assigned-to-me', (res) ->
    user = res.match[1]
    github.pullRequests.getAll({ user: github_user, repo: github_repo}, (err, pullRequests) ->
      pullRequestResponse = []
      _.each(pullRequests, (pr) ->
        opts = parse_pr(pr)
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
