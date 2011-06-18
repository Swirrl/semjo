require 'bundler/capistrano' # enable bundler stuff!

# rvm stuff
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.8.7'        # Or whatever env you want it to run in.
set :rvm_type, :user 
###

set :application, "semjo"

server "web1.swirrl.com", :app, :web, :db, :primary => true

set(:deploy_to) { File.join("", "home", user, application) }

set :config_files, %w(config.yml)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 2224

set :repository,  "git@github.com:Swirrl/semjo.git"
set :scm, "git"
set :branch, "master"

set :user, "rails"
set :runner, "rails"
set :admin_runner, "rails"
set :use_sudo, false

after "deploy:setup", "deploy:upload_app_config"
after "deploy:symlink", "deploy:symlink_app_config", "deploy:symlink_themes"
after "deploy:finalize_update", "deploy:update_design_docs" 

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
  end
  
  task :update_design_docs do
    run "cd #{current_path}; rails runner 'CouchRestMigration::update_all_design_docs' -e production"
  end
  
  desc "Copy local config files from app's config folder to shared_path."
  task :upload_app_config do
    config_files.each { |filename| put(File.read("config/#{filename}"), "#{shared_path}/#{filename}", :mode => 0640) }
  end

  desc "Symlink the application's config files specified in :config_files to the latest release"
  task :symlink_app_config do
    config_files.each { |filename| run "ln -nfs #{shared_path}/#{filename} #{latest_release}/config/#{filename}" }
  end
  
  task :symlink_themes do
    run "rm -rf #{current_path}/app/views/themes/symlinked"
    run "mkdir #{current_path}/app/views/themes/symlinked"
    run "ln -fs #{shared_path}/themes/* #{current_path}/app/views/themes/symlinked/"
  end
  
end

#require 'config/boot'
#require 'hoptoad_notifier/capistrano'
