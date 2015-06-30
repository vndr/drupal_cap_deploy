load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

require 'capistrano/ext/multistage'

# =============================================
# Script variables. These must be set in client capfile.
# =============================================
_cset(:stage_db)             { abort "Please specify the Drupal database name (:stage_db)." }
_cset(:stage_db_username)         { abort "Please specify the Drupal database username (:stage_db_username)." }
_cset(:stage_db_password)         { abort "Please specify the Drupal database password (:stage_db_password)." }
_cset(:stage_repository)   { abort "Please specify the Drupal repository (:stage_repository)." }
_cset(:stage_branch)   { abort "Please specify the Drupal repository branch (:stage_branch)." }
_cset(:stage_domain_name)   { abort "Please specify stage domain name (:stage_domain_name)." }
_cset(:stage_drupal_username)   { abort "Please specify stage drupal user name (:stage_drupal_username)." }
_cset(:stage_drupal_userpass)   { abort "Please specify stage drupal user pass (:stage_drupal_userpass)." }
_cset(:stage_drupal_usermail)   { abort "Please specify stage drupal user email (:stage_drupal_usermail)." }
_cset(:stage_domain_deploy_to)  { abort "Please specify stage domain deploy to  (:stage_domain_deploy_to)"}


namespace :deploy do
 
# =============================================
# default deploy function, just a wrapper function for all other tasks below
# =============================================
  desc <<-DESC 
          Deploys example.org to all defined stages. 
          It supposes that the Setup task was already executed. 
          Just a wrapper function for all other tasks below "
        DESC
  
    task :default, :roles => :app, :except => { :primary => true } do
      update_code
      drupal.settings
      drupal.files.create_files
      symlink
      drupal.set_owner
    end

    desc "Flush memcache"
    task :flush_memcache, :roles => :app do
        run "echo 'flush_all' | nc localhost 11211"
    end

    task :cleanup_drupal_files, :except => { :no_release => true } do
      count = fetch(:keep_releases, 5).to_i
      local_releases = capture("ls -xt #{releases_path}").split.reverse
      if count >= local_releases.length
        logger.important "no old releases to clean up"
      else
        logger.info "keeping #{count} of #{local_releases.length} deployed releases"
        directories = (local_releases - local_releases.last(count)).map { |release| File.join(releases_path, release) }.join(" ")
#        try_sudo "rm -rf #{directories}"
#        run "sudo -u www-data chmod -R g+w #{directories}"
        run "rm -rf #{directories}"

      end
    end

 #this task should be run across all installed sites, cos it will drop all databases
  namespace :mysql do
    task :create_db, :roles => :db , :only => { :primary => true } do
      if exists?(:current_site) then
        current_site.each do |site|
          run "mysql -u #{stage_db_username} -p#{stage_db_password} -e 'drop database if exists #{site}_drupal;'"
          run "mysql -u #{stage_db_username} -p#{stage_db_password} -e 'create database #{site}_drupal;'"    
        end
      end
    end
    
    desc "Change user email address created by profile script"
    task :set_user_email, :roles => :db, :only => { :primary => true } do
      drupal_sites.each do |site|
        run "mysql -u #{stage_db_username} -p#{stage_db_password} -e 'use #{site}_drupal; UPDATE users set mail = \"#{stage_drupal_usermail}\" WHERE uid=1;'"
      end
    end

    desc "Change user password created by profile script"
    task :set_user_pass, :roles => :db, :only => { :primary => true } do
      drupal_sites.each do |site|
        run "mysql -u #{stage_db_username} -p#{stage_db_password} -e 'use #{site}_drupal; UPDATE users set pass = MD5(\"#{stage_drupal_userpass}\") WHERE uid=1;'"
      end
    end

    desc "Taking copy of latest live db dump from backup server to staging server"
    task :copy_latest_db_dump, :roles => :backup do
      drupal_sites.each do |site|
        download("/var/lib/jenkins/db_dumps/#{site}/#{site}_drupal-dump.gz", "/tmp/#{site}_drupal-dump.gz")
      end
    end

    desc "Import latest db dump"
    task :import_latest_db_dump, :roles => :db, :only => { :primary => true } do
      drupal_sites.each do |site|
          transfer :up, "/tmp/#{site}_drupal-dump.gz","/tmp/#{site}_drupal-dump_2.gz"
          run "gunzip < /tmp/#{site}_drupal-dump_2.gz | mysql -u #{stage_db_username} -p#{stage_db_password} #{site}_drupal"
      end
    end

    desc "Add database import date"
    task :add_database_import_date, :roles => :db, :only => { :primary => true } do
      drupal_sites.each do |site|
        run "cd #{current_site_path}/#{site}.#{domain_name}/ && drush vset db_import_date `date +%s` -y"
      end
    end
  end

  namespace :drupal do

    def drupal_settings(site)

   settings = <<-STRING
<?php
    
        $db_prefix = '';
      
        $userpass = "#{db_username}:#{db_password}";
        $site = "#{site}.#{domain_name}";

        $db_host_name = "#{stage_dbnode}";
        $db_name = "#{site}_drupal";

        include("settings.inc");
        
    STRING
    end
    
    desc "Symlinks the any extra domain links for specific sites"
    task :symlink_domains, :roles => :app do
      drupal_sites.each do |site|
        if site == 'brasil'
          run "cd #{current_site_path}/ && ln -s #{site}.#{domain_name}/ example.org.br"
        end
        if site == 'india'
          run "cd #{current_site_path}/ && ln -s #{site}.#{domain_name}/ example.org.in"
        end
        if site == 'china'
          run "cd #{current_site_path}/ && ln -s #{site}.#{domain_name}/ zh.example.org"
        end
        if site == 'colombia'
          run "cd #{current_site_path}/ && ln -s #{site}.#{domain_name}/ example.org"
        end
      end
    end

    desc "Creates the Drupal settings file."
    task :settings, :roles => :app do
      drupal_sites.each do |site|
        put drupal_settings(site), "#{stage_sites_path}/#{site}.#{stage_domain_name}/settings.php"
        run "chmod 775 #{stage_sites_path}/#{site}.#{domain_name}/settings.php"
      end
    end

    desc "Flush drupal cache with drush"
    task :clear_cache, :roles => :app do
      drupal_sites.each do |site|
        run "cd #{current_site_path}/#{site}.#{domain_name}/ && drush cc all"
      end
    end
    
    desc "Revert all drupal features with drush"
    task :revert_features, :roles => :app do
      drupal_sites.each do |site|
        run "cd #{current_site_path}/#{site}.#{domain_name}/ && drush example_revert_features"
      end
    end

    desc "Update drupal project code and apply any database updates required (update.php)"
    task :drush_update, :roles => :app do
      drupal_sites.each do |site|
        run "cd #{current_site_path}/#{site}.#{domain_name}/ && drush updatedb -y"
      end
    end

    desc "Set appropriate group ownership"
    task :set_owner, :roles => :app do
      drupal_sites.each do |site|
        run "chown -R :www-data #{release_path}/*"
      end
    end

    desc "Export new and edited content from staging server"
    task :drush_export_content, :roles => :app do
      drupal_sites.each do |site|
          run "cd #{current_site_path}/#{site}.#{domain_name}/ && git checkout -b dev origin/dev && tstamp=`drush vget db_import_date | grep -E '[0-9]{10}' -o` && drush node-export-export --format=xml --sql=\"SELECT nid FROM node WHERE changed > ${tstamp}\" --file=\"#{content_folder}${tstamp}.xml\" -u admin -y && git add ../../profiles/example_distribution/content/#{site}.#{domain_name}/${tstamp}.xml && git commit -m'adding ${tstamp}.xml to exported content from staging server' && git push origin dev"
      end
    end


    namespace :files do
      # a new task
	# check for environment
 	# run either create_files or symlink_files

      desc "Creates the Drupal files directory"
      task :create_files, :roles => :app do
       
          if stage_create_drupal_files_dir == 'true'
            drupal_sites.each do |site|
              run "mkdir #{stage_sites_path}/#{site}.#{domain_name}/files" 
              run "chmod -R 775 #{stage_sites_path}/#{site}.#{domain_name}/files"
            end
          else
            drupal.files.symlink_files
      	  end
      end
    
      desc "Symlinks the Drupal shared files directory"
      task :symlink_files, :roles => :app do
        drupal_sites.each do |site|
          run "cd #{stage_sites_path}/#{site}.#{domain_name}/ && ln -s #{shared_files_dir}/#{site} files"
        end
      end
      
      desc "Download live files directory"
      task :download_files_directory, :roles => :backup do
        drupal_sites.each do |site|
          download("/var/lib/jenkins/file_dumps/#{site}_images/", "/tmp", {:recursive => true,:via => :scp})
        end
      end

      desc "Upload files directory"
      task :upload_files_directory, :roles => :app , :only => { :primary => true } do
        drupal_sites.each do |site|
              run "rm -rf #{current_site_path}/#{site}.#{domain_name}/files/images"
              transfer :up, "/tmp/#{site}_images","#{current_site_path}/#{site}.#{domain_name}/files/images", {:recursive => true,:via => :scp}
        end
      end
    end

    desc "Creates the Drupal .htaccess file"
    task :htaccess, :roles => :app do
      run "cp #{latest_release}/htaccess #{latest_release}/.htaccess"
    end
 end
end
