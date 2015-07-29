# Description:
#   サーバ内のログファイルより特定文字列の検索を行うスクリプトを実行し結果をChatworkに送る
# Author:
#   ssugawara
#

connection = require('ssh2')
config = require('./config/config')

module.exports = (robot) ->
	robot.respond /search log campaign ([\'\"]{1}[a-zA-Z0-9_\-\.\?/:&\[\],\s]*[\'\"]{1})\s*([0-9\/]+)*$/, (msg) ->
		msg.send "searching..."
		target_string = msg.match[1]
		# 検索対象文字列の前後のクォートを除去
		target_string = target_string.replace(/^[\"\']/, "")
		target_string = target_string.replace(/[\"\']$/, "")
		# 対象日付
		target_date = ""
		if msg.match[2]
			target_date = msg.match[2]
		# 実行コマンド
		command_su = "sudo su - nmadmin\n"
		command_cd = "cd /tmp\n"
		command_exec_sh = ""
		for server_host in config.ssh_log_server_host_list
			command_exec_sh = command_exec_sh + "sh ./search_log_files.sh \"#{server_host}\" \"#{config.ssh_log_server_user}\" '#{target_string}' #{target_date}\n"
		command_exit = "exit\nexit\n"
		command = command_su + command_cd + command_exec_sh + command_exit
		result = ""
		result_line = ""
		response = ""
		conn = new connection()
		conn.on 'ready', () ->
			conn.shell (err, stream) ->
				if err
					msg.send err
					conn.end()
					return
				stream.on 'close', () ->
					conn.end()
					result_line = result.split('\n')
					for value, i in result_line
						if i > config.output_start_line_number
							value = value.replace(/&/g,"＆")
							response = response + value + '\n'
					msg.send ">>> #{response.toString()}"
				.on 'data', (data) ->
					result = result + data
				.stderr.on 'data', (data) ->
					result = result + data
				stream.end(command)
		.connect({
			host: config.ssh_host,
			port: config.ssh_port,
			username: config.ssh_user,
			privateKey: require('fs').readFileSync(config.ssh_key),
			passphrase: config.ssh_pass
		})
