# Backend Processing & Management Dashboard Server

This server demonstrates handling both the backend processing and the management dashboard of our IoT solution.

## Setting up you environment

The azure-event-hubs node module currently has a bug which we have worked around in our fork. Until the PR is accepted you'll need to clone our repo in a sibling directory to this directory or update the path in ```package.json```

You can us commands like the following to set this up.

```bash
$ cd ..
$ git clone https://github.com/seank-com/azure-event-hubs.git
$ cd azure-event-hubs
$ git checkout develop
$ git pull
```

Then you can setup the rest of the dependencies by running the usual npm command

```bash
npm install
```

This server utilizes ```.env``` configuration files. This keeps you from pushing credentials to your repository. Before running the server, create a ```.env``` file in the same directory as ```app.js``` and put the following

```
IOT_HUB_CONNECTIONSTRING=<your IoTHub iothubowner connection string>
SQL_CONNECTIONSTRING=<Your SQL database connection string>
```

The server also expects to find a logs directory where ```app.js``` is and will enable viewing the file in that directory from the management dashboard.

## Running

You can run the server locally using the following command

```bash
node app.js
```

or for an experience more like production

```bash
node app.js >>logs/out.log 2>>logs/err.log
```

## Setting up a Node server

The following steps are for deploying to a raspbian version of Linux. Depending on your version you may need to adjust some commands but should point you in the right direction

SSH and run the following commands to install node and nginx

```bash
$ sudo apt-get remove -y nodered
$ sudo apt-get remove -y nodejs nodejs-legacy
$ curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
$ sudo apt-get update
$ sudo apt-get dist-upgrade
$ sudo apt-get install -y nodejs
$ sudo apt-get install -y git
$ sudo apt-get install -y nginx
$ sudo apt-get install -y xrdp
$ sudo apt-get autoremove
$ sudo /etc/init.d/nginx stop
```

Now setup the node server

```bash
$ sudo su -
$ useradd node
$ exit
$ sudo mkdir /var/node
$ sudo mkdir /var/node/logs
$ sudo chown -R $(whoami):node /var/node
$ sudo chmod 775 /var/node/logs
$ sudo mkdir /var/forever
$ sudo chown $(whoami):node /var/forever
$ sudo chmod 775 /var/forever
$ sudo mkdir /var/azure-event-hubs
$ sudo chown -R $(whoami):node /var/azure-event-hubs
$ git clone https://github.com/seank-com/azure-event-hubs.git /var/azure-event-hubs
$ cd /var/azure-event-hubs
$ git checkout develop
$ git pull
```

Getting it ready to run forever

```bash
$ npm install forever -g
$ nano /var/node/forever.json
```

Paste the following for /etc/init.d/iot-server

```
{
  "uid": "iot-server",
  "append": true,
  "script": "app.js",
  "path": "/var/forever",
  "sourceDir": "/var/node",
  "workingDir": "/var/node",
  "killSignal": "SIGTERM",
  "logFile": "/var/node/logs/forever.log",
  "outFile": "/var/node/logs/out.log",
  "errFile": "/var/node/logs/err.log"
}
```

Now make it a service

```bash
$ sudo touch /etc/init.d/iot-server
$ sudo chmod 755 /etc/init.d/iot-server
$ sudo nano /etc/init.d/iot-server
```

Paste the following for /etc/init.d/iot-server

```
### BEGIN INIT INFO
# Provides:             iot-server
# Required-Start:
# Required-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    IoT Server Node App
### END INIT INFO

case "$1" in
  start)
    sudo su node -c 'FOREVER_ROOT=/var/forever /usr/bin/forever start /var/node/forever.json'
    ;;
  stop)
    sudo su node -c 'FOREVER_ROOT=/var/forever /usr/bin/forever stop iot-server'
    ;;
  *)

  echo "Usage: /etc/init.d/iot-server {start|stop}"
  exit 1
  ;;
esac
exit 0
```

*Note:* if you ever need to list the forever process running you should run the following.
```bash
sudo su node -c 'FOREVER_ROOT=/var/forever /usr/bin/forever list'
```

Now configure logrotate to handle the logs

```bash
$ sudo nano etc/logrotate.d/iot-server
```

Paste the following

```
/var/node/logs/*.log {
  daily
  missingok
  size 100k
  rotate 7
  notifempty
  su pi node
  create 0764 pi node
  nomail
  sharedscripts
  prerotate
    sudo /etc/init.d/iot-server stop >/dev/null 2>&1
  endscript
  postrotate
    sudo /etc/init.d/iot-server start >/dev/null 2>&1
  endscript
}
```

*Note:* if you want to test/force rotation run the following
```bash
sudo logrotate -f /etc/logrotate.conf
```

Now configure Nginx

```bash
$ sudo nano /etc/nginx/sites-enabled/default
```

Replace the contents of /etc/nginx/sites-enabled/default with
the following

```
##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# HTTP server
server {
  listen 		80 default;
  server_name 	iot-server;

  # Proxy pass-though to the local node server
  location / {
    proxy_pass http://127.0.0.1:4000/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_connect_timeout       300;
    proxy_send_timeout          300;
    proxy_read_timeout          300;
    send_timeout                300;
  }
}
```

Register and start services

```bash
$ sudo update-rc.d iot-server defaults
$ sudo /etc/init.d/iot-server start
$ sudo /etc/init.d/nginx start
```
