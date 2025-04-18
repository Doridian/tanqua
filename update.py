#!/usr/bin/env python3

# Yes, this encoder is incredibly dumb. Sue me.

import serial
import sys
import time

END_STR = b"\x1b[34m>>\x1b[0m"
END_STR2 = b" \xe2\x86\x92"

with open("tanqua.lua", "r") as f:
    data = f.readlines()

def dumb_encode(data):
    return data.replace("\\", "\\\\").replace("'", "\\'").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")

serial_port = sys.argv[1]
dev = serial.Serial(serial_port, 115200, timeout=1)

def drain_buffer():
    return dev.read_all()

def shell_send(txt: str):
    #drain_buffer()

    dev.write((txt + "\n").encode())
    dev.flush()

    x = b""
    while True:
        xn = dev.read_until(b" ")
        x += xn
        sys.stdout.write(xn.decode("latin1"))
        sys.stdout.flush()

        xt = x.strip()
        if xt.endswith(END_STR):
            break
        if xt.endswith(END_STR2):
            dev.write(b"lua\n")

shell_send("")

shell_send('f = io.open("/sd/.themes/tanqua.lua","w")')
for line in data:
    shell_send('f:write("' + dumb_encode(line) + '")')
shell_send('f:close()')
