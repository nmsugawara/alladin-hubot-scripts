# Description: サーバ内のログファイルより特定文字列の検索を行うスクリプトを実行し結果をChatworkに送る
#
#

connection = require('ssh2')
config = require('./config/config')

module.exports = (robot) ->
	robot.respond /search log campaign (.*) (.*)$/i, (msg) ->
		target_string = msg.match[1]
		target_date = msg.match[2]
		command_su = "sudo su - nmadmin\n"
		command_cd = "cd /tmp\n"
		command_exec_sh = "sh /tmp/search_log_files.sh \"#{target_string}\" #{target_date}\n"
		result = ""
		conn = new connection()
		conn.on 'ready', () ->
			conn.shell (err, stream) ->
				if err
					console.log err
					msg.send err
					conn.end()
					return
				stream.on 'close', () ->
					conn.end()
					msg.send ">>> #{result.toString()}"
				.on 'data', (data) ->
					result = result + data
					msg.send "#{result}"
				.stderr.on 'data', (data) ->
					console.log 'STDERR: ' + data
					result = data
				stream.end(command_su && command_cd && command_exec_sh)
		.connect({
			host: config.ssh_host,
			port: config.ssh_port,
			username: config.ssh_user,
			privateKey: require('fs').readFileSync(config.ssh_key),
			passphrase: config.ssh_pass
		})
