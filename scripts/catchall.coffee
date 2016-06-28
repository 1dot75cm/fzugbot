# Description:
#   Catch all of message commands
#
# Author:
#   1dot75cm

module.exports = (robot) ->
  robot.catchAll (res) ->
    res.send "主人，无法识别您的指令：#{res.message.text}"
