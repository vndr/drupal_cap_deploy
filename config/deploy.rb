set :default_stage, "development"
set :stages, %w(production qa staging development)
require 'capistrano/ext/multistage'

set :application, "example_distro" # /var/www/example_distro/{current,releases,share} and vhost needst to point to current dir
set :user, "webdeploy"

set :dbnode, "localhost"

set (:stage_user) {"#{user}"}
set (:stage_user_path) {"#{user_path}"}

set :scm_username,  "gitolite"
set :scm, :git
set :repository, "gitolite@jaguar.intsec.example.org:example_distribution"

if ENV.has_key?('branch')
 set :branch, "#{ENV['branch']}"
else 
  set :branch, "dev"
end

if ENV.has_key?('drupal_username')
 set :drupal_username, "#{ENV['drupal_username']}"
else 
  set :drupal_username, "siteadmin"
end

if ENV.has_key?('create_drupal_files_dir')
 set :create_drupal_files_dir, "#{create_drupal_files_dir}"
end

if ENV.has_key?('drupal_userpass')
 set :drupal_userpass, "#{ENV['drupal_userpass']}"
else 
  set :drupal_userpass, "changemenow"
end

if ENV.has_key?('drupal_usermail')
 set :drupal_usermail, "#{ENV['drupal_usermail']}"
else 
  set :drupal_usermail, "mbrown@example.org"
end

if ENV.has_key?('domain_deploy_to')
  set :domain_deploy_to, "#{domain_deploy_to}"
end


default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :deploy_env, 'development'

set :use_sudo, false
set :db_username, "root"
set :db_password, "root"
set :db, "impact_drupal_deploy"

# if create_drupal_files_dir is false, a symlink of a 
# shared files directory (currently /mnt/www/files)
# will be created.  This is mostly for an environment 
# which has shared files directory (e.g. using glusterfs)
set :create_drupal_files_dir, true

set :site_path, "#{release_path}/sites"
set :current_site_path, "#{current_path}/sites"

set (:stage_sites_path) { "#{site_path}" }
set (:stage_db_username) { "#{db_username}" }
set (:stage_db_password) { "#{db_password}" }
set (:stage_db) { "#{db}" }
set (:stage_domain_name) { "#{domain_name}" }
set (:stage_branch) { "#{branch}" }
set (:stage_drupal_username) { "#{drupal_username}" }
set (:stage_drupal_usermail) { "#{drupal_usermail}" }
set (:stage_drupal_userpass) { "#{drupal_userpass}" }
set (:stage_dbnode) { "#{dbnode}" }
set (:stage_deploy_env) { "#{deploy_env}" }
set (:stage_create_drupal_files_dir) { "#{create_drupal_files_dir}" }
set (:stage_domain_deploy_to) {"#{domain_deploy_to}"}



#########

#This should be passed in using comma separated terms "brasil","india" etc ...

set :drupal_sites, ["brasil","india","china","colombia"]

if ENV.has_key?('current_site')
  set :current_site, eval(ENV['current_site']) #this is array for sites distribution {drupal_sites}.example.org 
end


set :domain_name, "example.org"



