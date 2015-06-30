set :domain_name, "example.org"

set :domain_deploy_to, "staging.brasil.#{domain_name}"

set :content_folder, "/var/www/example_distro/current/profiles/example_distribution/content/brasil.example.org/"

role :db, "#{domain_deploy_to}", :primary => true
role :app, "#{domain_deploy_to}"
role :backup, "ci.example.org", :no_release => true

set :dbnode, "localhost"

set :default_stage, "staging"
set :deploy_env, 'staging'

set :application, "example_distro"
set :user, "webdeploy"

set :scm_username,  "gitolite"
set :scm, :git
set :repository, "gitolite@jaguar:example_distribution"
set :branch, "dev"

set :drupal_username, "siteadmin"
set :drupal_usermail, "mbrown@example.org"
set :drupal_userpass, "changeme"

default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

set :keep_releases, 5

set :use_sudo, false
set :create_drupal_files_dir, true

set :db_username, "root"
set :db_password, "root"
set :db, "brasil_drupal"

set :site_path, "#{release_path}/sites"

before :deploy, "deploy:mysql:create_db"
after  :deploy, "deploy:drupal:htaccess"

