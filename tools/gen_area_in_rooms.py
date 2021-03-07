#!/usr/bin/python3

import sys, os

# now that we're in directory 'tools/' we have to update sys.path
sys.path.append(os.path.dirname(sys.path[0]))

# generate asm files putting graph area ID in "Unused Pointer" field's first byte in
# all room states

vanilla=sys.argv[1]
asm=sys.argv[2]

# area ID is index in this list
areas = ["Ceres", "Crateria", "GreenPinkBrinstar", "RedBrinstar", "WreckedShip", "Kraid", "Norfair", "Crocomire", "LowerNorfair", "WestMaridia", "EastMaridia", "Tourian"]

from rooms import rooms
from rom.rom import pc_to_snes,RealROM

rom = RealROM(vanilla)

statesChecksArgSize = {
    0xe5eb: 2,
    0xe612: 1,
    0xe629: 1
}

with open(asm, "w") as src:
    src.write("lorom\narch snes.cpu\n\n")
    for room in rooms:
#        print(room["Name"])
        def processState(stateWordAddr):
            src.write("org $8f%04x\n\tdb $%02x\n" % (stateWordAddr+16, areas.index(room['GraphArea'])))
        address = room['Address']+11
        # process additionnal states
        while True:
            w=rom.readWord(address)
            if w == 0xe5e6:
                break
            address += 2 + statesChecksArgSize.get(w, 0)
            processState(rom.readWord(address))
            address += 2
        # default state
        processState((address+2)-0x70000)
