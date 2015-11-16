# config valid only for current version of Capistrano
lock '3.4.0'

# Set the application name
set :application, 'fjarrkontrollen-server'

# Set the repository link
set :repo_url, 'https://github.com/ub-digit/fjarrkontrollen-server.git'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, '/apps/fjarrlan/fjarrkontrollen-server'

# Set tmp directory on remote host - Default value: '/tmp , which often will not allow files to be executed
set :tmp_dir, '/home/apps/tmp'

# Copy originals into /{app}/shared/config from respective sample file
#set :linked_files, %w{config/database.yml config/initializers/illbackend_cfg.rb config/initializers/secret_token.rb db/seeds/locations.rb db/seeds/testdata.rb db/seeds/users.rb}

set :rvm_ruby_version, "2.1.5"              # use the same ruby as used locally for deployment
