# ワーカーの数。後述
$worker  = 2
# 何秒経過すればワーカーを削除するのかを決める
$timeout = 30
# 自分のアプリケーション名、currentがつくことに注意。
$app_dir = "/var/www/syncpod/current"
# リクエストを受け取るポート番号を指定。後述
$listen  = File.expand_path "tmp/sockets/.unicorn.sock", $app_dir
# PIDの管理ファイルディレクトリ
$pid     = File.expand_path "tmp/pids/unicorn.pid", $app_dir
# エラーログを吐き出すファイルのディレクトリ
$std_log = File.expand_path "log/unicorn.log", $app_dir

# 上記で設定したものが適応されるよう定義
worker_processes  $worker
working_directory $app_dir
stderr_path $std_log
stdout_path $std_log
timeout $timeout
listen  $listen
pid $pid

# ホットデプロイをするかしないかを設定
preload_app true

# ホットデプロイを行うとGemと環境変数のloadをしてくれないので明示的にloadする
before_exec do |_server|
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/current/Gemfile"
  Bundler.require
  Dotenv.overload
end

# fork前に行うことを定義。後述
before_fork do |server, _worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

# fork後に行うことを定義。後述
after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
