# config valid only for current version of Capistrano
# lock '3.6.1'

set :application, 'z'
set :repo_url, 'git@github.umn.edu:latis-sw/z.git'
set :rbenv_ruby, File.read('.ruby-version').strip

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/swadm/web/z/'


set :monitrc_path, '/swadm/etc/monit.d/' 

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml', 'config/ldap.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
namespace :deploy do
  desc 'Restart Apache'
  task :apache do
    on roles(:app) do
      execute :sudo, "/bin/systemctl restart  httpd.service"
    end
  end
end

namespace :deploy do
  task :restart => 'monit:restart'
end

after 'deploy:apache', 'deploy:restart'

after 'deploy:symlink:release', 'deploy:apache'
