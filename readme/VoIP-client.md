
# Setting up VoIP clients

## How To Install pjsua and Asterisk on Ubuntu 20.04?
pjsua is a command-line based SIP user agent (softphone) application provided by the PJSIP project. PJSIP is a free and open-source multimedia communication library written in C. It supports audio, video, presence, and instant messaging communication. pjsua serves both as a useful SIP client for users and as a reference implementation for those wanting to understand how to use the PJSIP library.

Asterisk is a widely-used open-source framework for building communications applications, particularly those related to voice over IP (VoIP). Developed and maintained by Sangoma Technologies Corporation, Asterisk is used by businesses, call centers, carriers, and governments worldwide.

### Update the system:
```bash
sudo apt update
```
### Install pjsua :
```bash
sudo apt-get install make gcc pkg-config libasound2-dev libffi-dev python2.7-dev binutils libtool autoconf build-essential automake tcsh
wget https://github.com/pjsip/pjproject/archive/2.6.tar.gz
tar -xvf 2.6.tar.gz
cd pjproject-2.6
export CFLAGS="$CFLAGS -fPIC"
./configure && make dep && make
cd pjsip-apps/src/python
sudo python ./setup.py install
```
