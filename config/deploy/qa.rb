set :domain_name, "example.org"
set :domain_deploy_to, "qa.brasil.#{domain_name}"

#role :db, "#{domain_deploy_to}", :primary => true
#role :app, "#{domain_deploy_to}"

role :db, "192.168.1.68", :primary => true, :no_release=>true
role :app, "192.168.1.66", :primary => true
role :app, "192.168.1.67"
role :backup, "ci.example.org", :no_release => true

set :dbnode, "192.168.1.68"

set :default_stage, "qa"
set :deploy_env, 'qa'

set :application, "brasil.example.org"
set :user, "webdeploy"

set :scm_username,  "gitolite"
set :scm, :git
set :repository, "gitolite@jaguar.intsec.example.org:example_distribution"
#set :repository, "gitolite@jaguar:example_distribution"
#set :branch, "dev"

default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

set :deploy_to, "/var/www/example_distro"
set :deploy_via, :remote_cache

set :use_sudo, false
# if create_drupal_files_dir is false, a symlink of a 
# shared files directory (currently /mnt/www/files)
# will be created.  This is mostly for an environment 
# which has shared files directory (e.g. using glusterfs)
set :create_drupal_files_dir, false 	

# Drupal's Shared files directory
set :shared_files_dir, '/mnt/gluster/www'

set :db_username, "dbuser"
set :db_password, "changeme"
set :db, "brasil_drupal"

set :keep_releases, 5

set :site_path, "#{release_path}/sites"

set :domain_name, "example.org"

before :deploy, "deploy:mysql:create_db"
after  :deploy, "deploy:drupal:htaccess"

set :drupal_sites, ["brasil","india","china","colombia"]




