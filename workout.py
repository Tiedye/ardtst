def main():
    import serial
    s = serial.Serial("/dev/ttyACM0", baudrate=9600)
    while True:
        if (s.read(1) == b'A'):
            break
    s.write(b'\x01')
    while True:
        print(int.from_bytes(s.read(3), 'little', signed=True))

main()