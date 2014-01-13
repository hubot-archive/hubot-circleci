hubot-circleci
==============

Hubot CircleCI integration - get status and control CircleCI from hubot

## Config
HUBOT_CIRCLECI_TOKEN

## Commands
- `hubot circle me <user>/<repo> [branch]`  - Returns the build status of https://circleci.com/<user>/<repo>
- `hubot circle last <user>/<repo> [branch]`  - Returns the build status of the last complete build of https://circleci.com/<user>/<repo>
- `hubot circle retry <user>/<repo> [branch]`  - Retries the build
- `hubot circle cancel <user>/<repo> [branch]`  - Cancels the build
- `hubot circle clear <user>/<repo> [branch]`  - Clears the cache for the specified repo

## Notes
You can add an API token at https://circleci.com/account/api

## Author
[@dylanlingelbach]: https://github.com/dylanlingelbach/
