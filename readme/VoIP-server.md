# Setting up VoIP server
## How To Install FreeSWITCH PBX on Ubuntu 20.04?
FreeSWITCH is an open-source, multi-platform telephony platform designed for routing and interconnecting various communication protocols. It's often used for building voice and messaging products. 

### Update the system:
```bash
sudo apt -y update
```

### Install the dependencies
```bash
sudo apt install -y git subversion build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev libtool libtool-bin libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.2-dev libopus-dev cmake unzip
sudo apt install -y libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev python-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1-dev libavformat-dev libswscale-dev libpq-dev
```
### Install libks and singwalwire
```bash 
cd /usr/src
sudo git clone https://github.com/signalwire/libks.git
cd libks
sudo cmake .
sudo make
sudo make install
cd /usr/src
sudo git clone https://github.com/signalwire/signalwire-c.git
cd signalwire-c
sudo cmake .
sudo make
sudo make install
```
### Download source code of FreeSWITCH
```bash
cd /usr/src
sudo wget https://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.3.-release.zip
```

### Unzip and FreeSWITCH
```bash
sudo unzip freeswitch-1.10.3.-release.zip
cd freeswitch-1.10.3.-release/
sudo ./configure -C
sudo make
sudo make install
sudo make all cd-sounds-install cd-moh-install
```

### Creatin symlinks
```bash
sudo ln -s /usr/local/freeswitch/bin/freeswitch /usr/bin/
sudo ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin
```

### Create the new user for FreeSwitch to operate it with low privileges.
```bash
cd /usr/local
sudo groupadd freeswitch
sudo adduser --disabled-password --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH Voice Platform" --ingroup freeswitch freeswitch
sudo chown -R freeswitch:freeswitch /usr/local/freeswitch/
sudo chmod -R ug=rwX,o= /usr/local/freeswitch/
sudo chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/
```

### Edit the systemd file
```bash
sudo nano /etc/systemd/system/freeswitch.service
```

#### Add the following contents
```bash
[Unit]
Description=freeswitch
Wants=network-online.target
Requires=syslog.socket network.target local-fs.target
After=syslog.socket network.target network-online.target local-fs.target
[Service]
Type=forking
Environment="DAEMON_OPTS=-nonat"
EnvironmentFile=-/etc/default/freeswitch
ExecStartPre=/bin/chown -R freeswitch:freeswitch /usr/local/freeswitch
ExecStart=/usr/bin/freeswitch -u freeswitch -g freeswitch -ncwait $DAEMON_OPTS
TimeoutSec=45s
Restart=always
RestartSec=90
StartLimitInterval=0
StartLimitBurst=6
User=root
Group=daemon
LimitCORE=infinity
LimitNOFILE=100000
LimitNPROC=60000
LimitSTACK=250000
LimitRTPRIO=infinity
LimitRTTIME=infinity
IOSchedulingClass=realtime
IOSchedulingPriority=2
CPUSchedulingPolicy=rr
CPUSchedulingPriority=89
UMask=0007
NoNewPrivileges=false
[Install]
WantedBy=multi-user.target
```
### Edit the internal and external profiles with the IP addresses
```bash
To set server ip (private network): change the following 
    In sip_profiles/internal.xml,
        <param name="sip-ip" value="$${local_ip_v4}"/>   to  <param name="sip-ip" value="10.10.200.1"/>
        <param name="rtp-ip" value="$${local_ip_v4}"/>   to  <param name="rtp-ip" value="10.10.200.1"/>
    In sip_profile/external.xml,
        <param name="sip-ip" value="10.10.200.1"/>
        <param name="rtp-ip" value="10.10.200.1"/>
        <param name="ext-sip-ip" value="10.10.200.1"/>
        <param name="ext-rtp-ip" value="10.10.200.1"/>
    In vars.xml,
        <X-PRE-PROCESS cmd="stun-set" data="external_rtp_ip=10.10.200.1"/>
        <X-PRE-PROCESS cmd="stun-set" data="external_sip_ip=10.10.200.1"/>
```
### Start FreeSWITCH service and enable at startup
```bash
sudo chmod ugo+x freeswitch.service
sudo systemctl start freeswitch.service
sudo systemctl enable freeswitch.service
```



### Connect to FreeSwitch Client
```bash
fs_cli -r
```
