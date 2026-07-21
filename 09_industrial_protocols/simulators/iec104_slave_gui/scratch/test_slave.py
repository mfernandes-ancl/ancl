import socket
import time

def test_iec104_slave():
    # Connect to local IEC 104 Slave
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2.0)
    
    print("[Test] Connecting to 127.0.0.1:2404...")
    s.connect(("127.0.0.1", 2404))
    print("[Test] Connected!")
    
    # 1. Send STARTDT Act U-Frame
    # 0x68 (Start byte), 0x04 (Length), 0x07 (STARTDT Act), 0x00, 0x00, 0x00
    startdt_act = bytes([0x68, 0x04, 0x07, 0x00, 0x00, 0x00])
    print("[Test] Sending STARTDT Act...")
    s.sendall(startdt_act)
    
    # Read response
    resp = s.recv(1024)
    print(f"[Test] Received response ({len(resp)} bytes): {resp.hex().upper()}")
    
    # Check if response is STARTDT Con (0x0B in control fields)
    if len(resp) >= 6 and resp[0] == 0x68 and resp[2] == 0x0B:
        print("[SUCCESS] Received STARTDT Con!")
    else:
        print("[FAIL] Unexpected response to STARTDT Act.")
        s.close()
        return
        
    # 2. Send General Interrogation (GI) I-Frame
    # APCI: length = 14 (0x0E), control fields: Tx=0, Rx=0
    # ASDU: TI=100 (0x64), VSQ=1, COT=6 (Act), Org=0, CA=1, IOA=0, QOI=20 (0x14)
    gi_act = bytes([
        0x68, 0x0E,         # APCI header
        0x00, 0x00,         # Tx sequence = 0
        0x00, 0x00,         # Rx sequence = 0
        0x64,               # TI = 100
        0x01,               # VSQ = 1
        0x06, 0x00,         # COT = 6
        0x01, 0x00,         # CA = 1
        0x00, 0x00, 0x00,   # IOA = 0
        0x14                # QOI = 20
    ])
    
    print("[Test] Sending General Interrogation (GI)...")
    s.sendall(gi_act)
    
    # Read responses (we expect ACT CONFIRM, points updates, and ACT TERMINATION)
    time.sleep(0.5)
    
    resp = s.recv(4096)
    print(f"[Test] Received GI response ({len(resp)} bytes): {resp.hex().upper()}")
    
    # Parse responses
    offset = 0
    while offset < len(resp):
        if resp[offset] != 0x68:
            print(f"[Test] Invalid frame start at offset {offset}")
            break
            
        flen = resp[offset + 1]
        frame = resp[offset : offset + 2 + flen]
        print(f"  Frame: {frame.hex().upper()}")
        
        # Check frame type
        ctrl0 = frame[2]
        if (ctrl0 & 1) == 0:
            # I-Frame
            ti = frame[6]
            cot = frame[8] & 0x3F
            print(f"    I-Frame: TI={ti}, COT={cot}")
            if ti == 100:
                if cot == 7:
                    print("    -> GI Activation Confirm")
                elif cot == 10:
                    print("    -> GI Activation Termination")
            elif ti in [1, 3, 9, 11, 13, 30, 36]:
                vsq = frame[7]
                items = vsq & 0x7F
                ioa = frame[12] + (frame[13] << 8) + (frame[14] << 16)
                print(f"    -> Point Update: TI={ti}, COT={cot}, IOA={ioa}, Items={items}")
        elif (ctrl0 & 2) == 0:
            print("    -> S-Frame")
        else:
            print("    -> U-Frame")
            
        offset += 2 + flen

    s.close()
    print("[Test] Completed.")

if __name__ == "__main__":
    test_iec104_slave()
