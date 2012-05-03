require 'bundler/capistrano' # enable bundler stuff!

# rvm stuff
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2'        # Or whatever env you want it to run in.
set :rvm_type, :user
###

set :application, "semjo"

server "88.198.46.45", :app, :web, :db, :primary => true

set(:deploy_to) { File.join("", "home", user, "sites", application) }

set :config_files, %w(config.yml)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 22

set :repository,  "git@github.com:Swirrl/semjo.git"
set :scm, "git"
set :branch, "master"

set :deploy_via, :remote_cache

set :user, "rails"
set :runner, "rails"
set :admin_runner, "rails"
set :use_sudo, false



after "deploy:setup", "deploy:upload_app_config"
after "deploy:finalize_update", "deploy:symlink_app_config", "deploy:symlink_secret_token", "deploy:symlink_themes", "deploy:symlink_assets", "deploy:update_design_docs"


namespace :deploy do

  desc <<-DESC
    overriding deploy:cold task to not migrate...
  DESC
  task :cold do
    update
    start
  end

  desc <<-DESC
    overriding start to just call restart
  DESC
  task :start do
    restart
  end

  desc <<-DESC
    overriding stop to do nothing - you cant stop a passenger app!
  DESC
  task :stop do
  end

  desc <<-DESC
    overriding start to just touch the restart txt
  DESC
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    run "sudo echo 'flush_all' | nc localhost 11211" # flush memcached
  end

  task :update_design_docs do
    run "cd #{latest_release}; bundle exec rails runner 'CouchRestMigration::update_all_design_docs' -e production"
  end

  desc "Copy local config files from app's config folder to shared_path."
  task :upload_app_config do
    config_files.each { |filename| put(File.read("config/#{filename}"), "#{shared_path}/#{filename}", :mode => 0640) }
  end

  desc "Symlink the application's config files specified in :config_files to the latest release"
  task :symlink_app_config do
    config_files.each { |filename| run "ln -nfs #{shared_path}/#{filename} #{latest_release}/config/#{filename}" }
  end

  task :symlink_secret_token do
    run "ln -nfs #{shared_path}/secret_token.rb #{latest_release}/config/initializers/secret_token.rb"
  end

  task :symlink_themes do
    run "rm -rf #{latest_release}/app/views/themes/symlinked"
    run "mkdir -p #{latest_release}/app/views/themes/symlinked/"
    run "ln -fs #{shared_path}/themes/* #{latest_release}/app/views/themes/symlinked/"
    run "touch #{latest_release}/tmp/restart.txt"
    run "sudo echo 'flush_all' | nc localhost 11211" # flush memcached
  end

  task :symlink_assets do
    run "rm -rf #{latest_release}/public/theme_assets"
    run "mkdir -p #{latest_release}/public/theme_assets/"
    run "ln -fs #{shared_path}/assets/* #{latest_release}/public/theme_assets/"
    run "touch #{latest_release}/tmp/restart.txt"
    run "sudo echo 'flush_all' | nc localhost 11211" # flush memcached
  end


end
