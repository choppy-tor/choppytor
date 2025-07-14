# Sample use: python voip_callee.py 10.8.0.1 9001 1001 1234 30 8000 player/client_2_30s.wav recordings/callee_1_

import sys
import pjsua as pj
import threading
import time
import os
import wave
import os
import random

global NAME_RECORDED_FILE
global NAME_RECORDED_FILE_FOR_CALL

if len(sys.argv) < 7:
    print "Usages: python " + sys.argv[0] + " <voip-server-ip> <voip-server-sip-port> <sip-caller-id> <sip-caller-password> <call-timeout> <call-sampling-rate> <play-file-location> <recorded-file-name>"
    print sys.argv
    sys.exit(1)


VOIP_SERVER = sys.argv[1]
VOIP_SERVER_PORT = int(sys.argv[2])
SIP_CALLER_ID = sys.argv[3]
SIP_CALLER_PASSWORD = sys.argv[4]
CALL_TIMEOUT = int(sys.argv[5])
CALL_SAMPLING_RATE = int(sys.argv[6])
PLAY_FILE = sys.argv[7]
NAME_RECORDED_FILE = sys.argv[8]

RECORDING = True
current_call = None
start_time = None

# Logging callback
def log_cb(level, str, len):
    pass


def get_random_player():
    file_list = []
    for i in range(PLAY_FILE_DURATION // 5):
        option = random.randint(1, 5)
        if option < 5:
            file_list.append("player/speaker2.wav")
        else:
            file_list.append("player/speaker2.wav")
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
    
    def on_incoming_call(self, call):
        global current_call, start_time
        if current_call:
            call.answer(486, "Busy")
            return
           
        print "Incoming call from ", call.info().remote_uri
        
        current_call = call
        
        call_cb = MyCallCallback(current_call)
        current_call.set_callback(call_cb)
        
        current_call.answer(200)
        start_time = time.time()


class MyCallCallback(pj.CallCallback):
    recorder_slot_Id = None
    recorder_id = None
    record = False
    player_id = None
    player_slot_id = None
    
    def __init__(self, call=None):
        pj.CallCallback.__init__(self, call)
        self.record = RECORDING

    # Notification when call state has changed
    def on_state(self):
        global current_call
        print "Call with", self.call.info().remote_uri,
        print "is", self.call.info().state_text,
        print "last code =", self.call.info().last_code, 
        print "(" + self.call.info().last_reason + ")"
       
        if self.call.info().state == pj.CallState.DISCONNECTED:
            c_slot = self.call.info().conf_slot
            current_call = None
            lib.conf_disconnect(0, self.recorder_slot_Id)
            lib.recorder_destroy(self.recorder_id)
            lib.player_destroy(self.player_id)
            print 'Current call is', current_call
            self.player_id = None
            self.player_slot_id = None
            self.record = False
            self.recorder_id = None
            self.recorder_slot_Id = None

    # Notification when call's media state has changed.
    def on_media_state(self):
        if self.call.info().media_state == pj.MediaState.ACTIVE:
            global NAME_RECORDED_FILE_FOR_CALL
            # Connect the call to sound device
            call_slot = self.call.info().conf_slot
            lib.conf_connect(call_slot, 0)
            lib.conf_connect(0, call_slot)
            
            # file_list = get_random_player()
            # print(file_list)
            self.player_id = lib.create_player(PLAY_FILE, loop = True)
            self.player_slot_id = lib.player_get_slot(self.player_id)
            print "player Id : " + str(self.player_id) + " player Conference Slot Id: " + str(self.player_slot_id)
            lib.conf_connect(self.player_slot_id, 0)
            lib.conf_connect(self.player_slot_id, call_slot)
            print "Media is now active"
            
            if self.record == True:
                self.recorder_id = lib.create_recorder(NAME_RECORDED_FILE_FOR_CALL)
                print "Recorder id: " + str(self.recorder_id)
                self.recorder_slot_Id = lib.recorder_get_slot(self.recorder_id)
                lib.conf_connect(call_slot, self.recorder_slot_Id)
                # lib.conf_connect(self.player_slot_id, self.recorder_slot_Id)
                print "Recording Call..."
        else:
            print "Media is inactive"


try:
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
    transport = lib.create_transport(pj.TransportType.UDP, pj.TransportConfig(port=VOIP_SERVER_PORT, bound_addr=VOIP_SERVER))
    

    lib.start()

    # configure client account
    acc_cfg = pj.AccountConfig()
    acc_cfg.id = "sip:" + SIP_CALLER_ID + "@" + VOIP_SERVER
    acc_cfg.reg_uri = "sip:" + VOIP_SERVER
    acc_cfg.proxy = ["sip:" + VOIP_SERVER]
    acc_cfg.auth_cred = [pj.AuthCred(VOIP_SERVER, SIP_CALLER_ID, SIP_CALLER_PASSWORD)]
    acc_cfg.rtp_transport_cfg.bound_addr=VOIP_SERVER
    
    acc = lib.create_account(acc_cfg)
    acc_cb = MyAccountCallback(acc)
    acc.set_callback(acc_cb)
    acc_cb.wait()

    print "\n"
    print "Registration complete, status=", acc.info().reg_status, "(" + acc.info().reg_reason + ")"
    
    COUNT = 1
    global NAME_RECORDED_FILE_FOR_CALL
    NAME_RECORDED_FILE_FOR_CALL = NAME_RECORDED_FILE + str(COUNT) + ".wav"

    while(True):
        if start_time and time.time() - start_time > CALL_TIMEOUT:
            if not current_call:
                print "there is no call"
                continue
            current_call.hangup()
            COUNT += 1
            NAME_RECORDED_FILE_FOR_CALL = NAME_RECORDED_FILE + str(COUNT) + ".wav"
            start_time = None
        
    del call
    acc.delete()
    acc = None
    lib.destroy()
    lib = None

except pj.Error, e:
    acc.delete()
    acc = None
    lib.destroy()
    lib = None
    sys.exit(1)
