#!/bin/bash
#Based on https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/aws/standalone/oss/deploy_app_main.html#rails_update-your-gem-bundle

#Install repos and dependencies
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update
apt install -y git gnupg2 nodejs yarn

gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io -o /tmp/rvm.sh
cat /tmp/rvm.sh | bash -s stable --rails
source /usr/local/rvm/scripts/rvm
rvm install ruby-3.0.0


#Clone repo and prepare environment
sudo mkdir -p /var/www/myapp
cd /var/www/myapp
git clone https://github.com/jtreutel/circleci-rails-gcp.git code  #git checkout dev
cd /var/www/myapp/code
rvm use ruby-3.0.0
bundle config set deployment 'true'
bundle config set without 'development test'
bundle install
bundle exec rake assets:precompile db:migrate RAILS_ENV=production


#Create Passengerfile
cat - << EOF > /var/www/myapp/code/Passengerfile.json
{
  // Run the app in a production environment. The default value is "development".
  "environment": "production",
  // Run Passenger on port 80, the standard HTTP port.
  "port": 80,
  // Tell Passenger to daemonize into the background.
  "daemonize": true,
  // Tell Passenger to run the app as the given user. Only has effect
  // if Passenger was started with root privileges.
  "user": "root"
}
EOF


# Create systemd service file
cat - << EOF > /usr/lib/systemd/system/myapp.service
[Unit]
Description=MyApp
Requires=network.target
 
[Service]
Type=forking
PIDFile=/var/www/myapp/code/passenger.80.pid
User=root
Group=root
WorkingDirectory=/var/www/myapp/code
ExecStart=/usr/bin/bash -lc 'bundle exec passenger start'
TimeoutSec=30
RestartSec=15s
Restart=always
 
[Install]
WantedBy=multi-user.target
EOF

#Configure service to start automatically
systemctl enable myapp
systemctl start myapp