hubot-circleci
==============

Hubot CircleCI integration - get status and control CircleCI from hubot

## Config
| Variable | Description |
| -------- | ----------- |
| `HUBOT_CIRCLECI_TOKEN` | (Required) CircleCI API Token (can be added [here](https://circleci.com/account/api)) |
| `HUBOT_GITHUB_ORG`     | (Optional) Sets a default GitHUb organization so you can specify a repo without the preceeding organization name |

## Commands
- `hubot circle me <user>/<repo> [branch]`  - Returns the build status of [https://circleci.com/user/repo](https://circleci.com/), defaults to master
- `hubot circle last <user>/<repo> [branch]`  - Returns the build status of the last complete build of [https://circleci.com/user/repo](https://circleci.com/), defaults to master
- `hubot circle retry <user>/<repo> [last | build number]`  - Retries the specified build or the last build of master
- `hubot circle cancel <user>/<repo> [build number]`  - Cancels the specified build
- `hubot circle clear <user>/<repo>`  - Clears the cache for the specified repo

## Author
[dylanlingelbach](https://github.com/dylanlingelbach/)
