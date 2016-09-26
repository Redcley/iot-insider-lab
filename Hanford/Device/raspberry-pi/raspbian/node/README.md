# Node

This demonstrates a device running on Raspbian as a node process.

## Setting up you environment

```bash
npm install
```

This device utilizes ```.env``` configuration files. This keeps you from pushing credentials to your repository. Before running the server, create a ```.env``` file in the same directory as ```device.js``` and put the following

```
IOT_DEVICE_CONNECTIONSTRING=<your IoTHub iothubowner connection string>
```

The server also expects to find a logs directory where ```device.js``` is and will store logs there.

## Running

You can run the device locally using the following command

```bash
node device.js
```

or for an experience more like production

```bash
node device.js >>logs/out.log 2>>logs/err.log
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
$ sudo apt-get autoremove
```

Now setup the node server

```bash
$ sudo su -
$ useradd node
$ usermod -G i2c node
$ exit
$ sudo mkdir /var/node
$ sudo mkdir /var/node/logs
$ sudo chown -R $(whoami):node /var/node
$ sudo chmod 775 /var/node/logs
$ sudo mkdir /var/forever
$ sudo chown $(whoami):node /var/forever
$ sudo chmod 775 /var/forever
```

Getting it ready to run forever

```bash
$ npm install forever -g
$ nano /var/node/forever.json
```

Paste the following for /var/node/forever.json

```
{
  "uid": "iot-server",
  "append": true,
  "script": "device.js",
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

Register and start services

```bash
$ sudo update-rc.d iot-server defaults
$ sudo /etc/init.d/iot-server start
```
