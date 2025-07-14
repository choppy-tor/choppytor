# Sample use:
# python voip_caller.py recordings/caller_ 10.8.0.1 9001 1011 1234 1001 50 8000 unused_path 10.8.0.2

import sys
import pjsua as pj
import threading
import time
import os

global NAME_RECORDED_FILE
global NAME_RECORDED_FILE_FOR_CALL

if len(sys.argv) < 10:
    print "Usage: python " + sys.argv[0] + " <record-file-name> <voip-server-ip> <voip-server-sip-port> <sip-caller-id> <sip-caller-password> <sip-destination-number> <call-timeout> <call-sampling-rate> <unused-play-file-location> <client-ip>"
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
# PLAYFILE = sys.argv[9]  # Not used now
CLIENT_IP = sys.argv[9]

# Logging callback
def log_cb(level, str, len):
    pass

class MyAccountCallback(pj.AccountCallback):
    sem = None

    def __init__(self, account):
        pj.AccountCallback.__init__(self, account)

    def wait(self):
        self.sem = threading.Semaphore(0)
        self.sem.acquire()

    def on_reg_state(self):
        if self.sem and self.account.info().reg_status >= 200:
            self.sem.release()

class MyCallCallback(pj.CallCallback):
    recorder_slot_Id = None
    recorder_id = None
    record = False

    def __init__(self, call=None, record=False):
        pj.CallCallback.__init__(self, call)
        self.record = record

    def on_state(self):
        print "Call is", self.call.info().state_text,
        print "last code =", self.call.info().last_code,
        print "(" + self.call.info().last_reason + ")"

        if self.call.info().state == pj.CallState.DISCONNECTED and self.record:
            c_slot = self.call.info().conf_slot
            lib.conf_disconnect(0, self.recorder_slot_Id)
            lib.recorder_destroy(self.recorder_id)
            self.recorder_id = None
            self.recorder_slot_Id = None
            self.record = False

    def on_media_state(self):
        if self.call.info().media_state == pj.MediaState.ACTIVE:
            call_slot = self.call.info().conf_slot
            lib.conf_connect(call_slot, 0)
            lib.conf_connect(0, call_slot)

            if self.record:
                self.recorder_id = lib.create_recorder(NAME_RECORDED_FILE_FOR_CALL)
                print "Recorder id:", self.recorder_id
                self.recorder_slot_Id = lib.recorder_get_slot(self.recorder_id)
                lib.conf_connect(call_slot, self.recorder_slot_Id)
                print "Recording Call..."

try:
    lib = pj.Lib()

    med_conf = pj.MediaConfig()
    med_conf.clock_rate = CALL_SAMPLING_RATE

    ua_config = pj.UAConfig()
    ua_config.max_calls = 10000

    lib.init(ua_cfg=ua_config, log_cfg=pj.LogConfig(level=7, callback=log_cb), media_cfg=med_conf)
    lib.set_null_snd_dev()

    transport = lib.create_transport(pj.TransportType.UDP, pj.TransportConfig(port=VOIP_SERVER_PORT, bound_addr=CLIENT_IP))

    RECORDING = True
    lib.start()

    acc_cfg = pj.AccountConfig()
    acc_cfg.id = "sip:" + SIP_CALLER_ID + "@" + VOIP_SERVER
    acc_cfg.reg_uri = "sip:" + VOIP_SERVER
    acc_cfg.proxy = ["sip:" + VOIP_SERVER]
    acc_cfg.auth_cred = [pj.AuthCred(VOIP_SERVER, SIP_CALLER_ID, SIP_CALLER_PASSWORD)]
    acc_cfg.rtp_transport_cfg.bound_addr = CLIENT_IP

    acc = lib.create_account(acc_cfg)
    acc_cb = MyAccountCallback(acc)
    acc.set_callback(acc_cb)
    acc_cb.wait()

    print "\nRegistration complete, status =", acc.info().reg_status, "(" + acc.info().reg_reason + ")"

    dst = "sip:" + SIP_DESTINATION_NUMBER + "@" + VOIP_SERVER
    print "Call initiated to:", dst

    NAME_RECORDED_FILE_FOR_CALL = NAME_RECORDED_FILE + ".wav"
    call = acc.make_call(dst, MyCallCallback(record=RECORDING))

    time.sleep(CALL_TIMEOUT)
    print "We're done"

    del call
    acc.delete()
    acc = None
    lib.destroy()
    lib = None

except pj.Error, e:
    print "Exception:", str(e)
    try:
        acc.delete()
    except:
        pass
    acc = None
    lib.destroy()
    lib = None
    sys.exit(1)

