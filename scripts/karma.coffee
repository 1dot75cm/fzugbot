# Description:
#   Vote for the package, and publish to release repository
#
# Configuration:
#   HUBOT_REPO_PATH
#
# Commands:
#   hubot karma <+1|-1> <pkgname> - Vote for the package; 为rpm包投票
#
# Author:
#   1dot75cm

fs = require 'fs'
exec = require('child_process').exec
prefix = process.env['HUBOT_REPO_PATH'] || "."
karma = 2
list = []

searchSync = (path, patten) ->
  files = fs.readdirSync path
  for file in files
    stat = fs.statSync path+'/'+file
    if stat.isDirectory()
      searchSync path+'/'+file, patten
    else if file.match patten
      list.push path+'/'+file
  return list

module.exports = (robot) ->
  robot.hear /karma (.*) (.*)/i, (res) ->
    list = []
    value = res.match[1]
    pkgname = res.match[2]
    pkgs = searchSync prefix, pkgname+'.*.rpm$'
    if value not in ['+1', '-1']
      res.send "karma value Error. options: +1 or -1"
    else
      for pkg in pkgs
        pkgscore = 0
        pkgname = pkg.split('/').pop()
        pkgfile = fs.existsSync pkg
        scorefile = fs.existsSync pkg+'.score'
        if pkgfile and scorefile
          pkgscore = fs.readFileSync pkg+'.score'
        if value is '+1'
          pkgscore = Number(pkgscore) + 1
        else if value is '-1'
          pkgscore = Number(pkgscore) - 1
        res.send "#{pkgname} karma is #{pkgscore}"
        if pkgscore >= karma and pkgfile
          dest = pkg.replace 'testing', 'free'
          fs.renameSync pkg, dest
          fs.unlinkSync pkg+'.score'
          res.send "move #{pkgname} to fzug-free repository."
          destdir = dest.split('/')
          destdir.pop()
          destdir = destdir.join('/')
          exec 'createrepo_c '+destdir, (err, stdout, stderr) ->
            res.send 'create metadata.'
        else if pkgfile
          fs.writeFileSync pkg+'.score', pkgscore

