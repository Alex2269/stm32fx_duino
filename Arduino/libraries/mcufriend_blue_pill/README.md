
```
# stm32_blue_pill_tft

http://wiki.stm32duino.com/index.php?title=Blue_Pill

original lib:
https://github.com/prenticedavid/MCUFRIEND_kbv

depends: git
cd ${HOME}/Arduino/libraries/
git clone https://github.com/Alex2269/mcufriend_blue_pill
git clone https://github.com/adafruit/Adafruit-GFX-Library
or:
git clone git@github.com:Alex2269/mcufriend_blue_pill.git
git clone git@github.com:adafruit/Adafruit-GFX-Library.git

file connections - mcufriend_shield.h
See pcb directory for connections.
Changes only connections tft display with shift of pins:

 0 1 2 3 4 5 6 7 mcu GPIOA
 | | | | | | | |
 2 3 4 5 6 7 0 1 tft

 RD WR CD CS RST tft
 |   |  |  |  |
 5   6  7  8  9 mcu GPIOB

#define RD_PIN  5
#define WR_PIN  6
#define CD_PIN  7
#define CS_PIN  8
#define RESET_PIN  9

now touch not working
 ```
