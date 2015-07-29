# Description:
#   週次監視タスクの通知を行う
# Author:
#   ssugawara
#

cron = require('cron').CronJob
config = require('./config/config')

module.exports = (robot) ->
	# 毎週木曜日AM10:00に通知
	job = new cron '0 10 * * 4', ->
		robot.send room: "#{config.chatwork_room_id}", "#{selectWorker()}"
	job.start()

worker_list = [
	'澁谷',
	'ほりちゃん',
	'菅原'
]

selectWorker = ->
	worker = worker_list[Math.floor(Math.random()*2)]
	"週次監視の日だよー\n 今日は#{worker}にやってもらいたいなー"
