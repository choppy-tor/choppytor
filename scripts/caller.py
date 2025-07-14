# $Id: simplecall.py 2171 2008-07-24 09:01:33Z bennylp $
#
# SIP account and registration sample. In this sample, the program
# will block to wait until registration is complete
#
# Copyright (C) 2003-2008 Benny Prijono <benny@prijono.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# Sample use: python2.7 VOIP/voip_caller.py VOIP/recordings/caller_ 10.8.0.1 9001 1011 1234 1001 50 8000 VOIP/player/client_1_30s.wav 10.8.0.2

import sys
import pjsua as pj
import threading
import time
import os
import wave
import random

global NAME_RECORDED_FILE
global NAME_RECORDED_FILE_FOR_CALL

if len(sys.argv) < 9:
    print "Usages: python " + sys.argv[0] + " <record-file-name> <voip-server-ip> <voip-server-sip-port> <sip-caller-id> <sip-caller-password> <sip-destication-number> <call-timeout> <call-sampling-rate> <play-file-location> <client-ip>"
    print sys.argv
    sys.exit(1)

NAME_RECORDED_FILE = sys.argv[1]
VOIP_SERVER = sys.argv[2]
VOIP_SERVER_PORT = int(sys.argv[3])
SIP_CALLER_ID = sys.argv[4]
SIP_CALLER_PASSWORD = sys.argv[5]
SIP_DESTINATION_NUMBER = sys.argv[6]
CALL_TIMEOUT = int(sys.argv[7])
CALL_SAMPLING_RATE = int(sys.argv[8])
PLAYFILE = sys.argv[9]
CLIENT_IP = sys.argv[10]

# Logging callback
def log_cb(level, str, len):
    pass

def get_random_player():
    file_list = []
    for i in range(PLAY_FILE_DURATION // 5):
        option = random.randint(1, 5)
        if option < 5:
            file_list.append("player/speaker1.wav")
        else:
            file_list.append("player/speaker1.wav")
    return file_list

class MyAccountCallback(pj.AccountCallback):
    sem = None
    HANGUP = False

    def __init__(self, account):
        pj.AccountCallback.__init__(self, account)

    def wait(self):
        self.sem = threading.Semaphore(0)
        self.sem.acquire()

    def on_reg_state(self):
        if self.sem:
            if self.account.info().reg_status >= 200:
                self.sem.release()


# Callback to receive events from Call
class MyCallCallback(pj.CallCallback):
    recorder_slot_Id = None
    recorder_id = None
    record = False
    player_id = None
    player_slot_id = None

    def __init__(self, call=None, record=False):
        pj.CallCallback.__init__(self, call)
        self.record = record

    # Notification when call state has changed
    def on_state(self):
        print "Call is ", self.call.info().state_text,
        print "last code =", self.call.info().last_code,
        print "(" + self.call.info().last_reason + ")"
        if self.call.info().state == 6 and self.record == True:  # 6==DISCONNECTED
            c_slot = self.call.info().conf_slot
            lib.conf_disconnect(0, self.recorder_slot_Id)
            lib.recorder_destroy(self.recorder_id)
            lib.player_destroy(self.player_id)
            self.record = False
            self.recorder_id = None
            self.recorder_slot_Id = None
            self.player_id = None
            self.player_slot_id = None

    # Notification when call's media state has changed.
    def on_media_state(self):
        global lib
        prev = self.call.info().media_state

        if self.call.info().media_state == pj.MediaState.ACTIVE:
            # Connect the call to sound device
            call_slot = self.call.info().conf_slot
            lib.conf_connect(call_slot, 0)
            lib.conf_connect(0, call_slot)
            
            self.player_id = lib.create_player(PLAYFILE, loop = True)
            self.player_slot_id = lib.player_get_slot(self.player_id)
            print "player Id : " + str(self.player_id) + " player Conference Slot Id: " + str(self.player_slot_id)
            lib.conf_connect(self.player_slot_id, 0)
            lib.conf_connect(self.player_slot_id, call_slot)

            if self.record == True:
                self.recorder_id = lib.create_recorder(NAME_RECORDED_FILE_FOR_CALL)
                print "Recorder id: " + str(self.recorder_id)
                self.recorder_slot_Id = lib.recorder_get_slot(self.recorder_id)
                lib.conf_connect(call_slot, self.recorder_slot_Id)
                # lib.conf_connect(self.player_slot_id, self.recorder_slot_Id)
                print "Recording Call..."

                

try:
    #print "Inside record-samples.py script"
    # Create library instance
    lib = pj.Lib()

    # Init library with default config
    med_conf = pj.MediaConfig()
    med_conf.clock_rate = CALL_SAMPLING_RATE
    
    ua_config = pj.UAConfig()
    ua_config.max_calls = 10000 
    lib.init(ua_cfg=ua_config, log_cfg=pj.LogConfig(level=7, callback=log_cb), media_cfg=med_conf)
    # Remedy the non availibility of sound device
    lib.set_null_snd_dev()

    # Create UDP transport which listens to any available port
    transport = lib.create_transport(pj.TransportType.UDP, pj.TransportConfig(port=VOIP_SERVER_PORT, bound_addr=CLIENT_IP))

    RECORDING = True
    lib.start()

    # configure client account
    acc_cfg = pj.AccountConfig()
    acc_cfg.id = "sip:" + SIP_CALLER_ID + "@" + VOIP_SERVER
    acc_cfg.reg_uri = "sip:" + VOIP_SERVER
    acc_cfg.proxy = ["sip:" + VOIP_SERVER]
    acc_cfg.auth_cred = [pj.AuthCred(VOIP_SERVER, SIP_CALLER_ID, SIP_CALLER_PASSWORD)]
    acc_cfg.rtp_transport_cfg.bound_addr=CLIENT_IP
    
    acc = lib.create_account(acc_cfg)
    acc_cb = MyAccountCallback(acc)
    acc.set_callback(acc_cb)
    acc_cb.wait()

    print "\n"
    print "Registration complete, status=", acc.info().reg_status, "(" + acc.info().reg_reason + ")"
     
    print "destination - (sip:xxx@host):"
    dst = "sip:" + SIP_DESTINATION_NUMBER + "@" + VOIP_SERVER
    print dst
   
    print "Call initiated"
    global NAME_RECORDED_FILE_FOR_CALL
    NAME_RECORDED_FILE_FOR_CALL = NAME_RECORDED_FILE + ".wav"
    call = acc.make_call(dst, MyCallCallback(record=RECORDING))
    time.sleep(CALL_TIMEOUT)
    print "We're done"


    del call
    acc.delete()
    acc = None
    # We're done, shutdown the library
    lib.destroy()
    lib = None

except pj.Error, e:
    print "Exception: " + str(e)
    acc.delete()
    acc = None
    lib.destroy()
    lib = None
    sys.exit(1)
