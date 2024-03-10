
###: select board
include Makefile_board_bluepill.mk
# include Makefile_board_nucleo_411re.mk
# include Makefile_board_nucleo_446re.mk

###: List library names you only use in your sources
ARDUINO_LIBR += SPI
ARDUINO_LIBR += SoftwareSerial
ARDUINO_LIBR += SD
ARDUINO_LIBR += SeeedGrayOLED
ARDUINO_LIBR += USBcore
ARDUINO_LIBR += Wire

###: USER_LIB_PATH ?= ${HOME}/Arduino/libraries
USER_LIB_PATH += Arduino/libraries


USER_LIBR += Adafruit-GFX
USER_LIBR += Adafruit_BusIO
# USER_LIBR += MCUFRIEND_kbv
# USER_LIBR += BlueVGA
# USER_LIBR += MCUFRIEND_kbv MCUFRIEND_kbv/examples/TouchScreen_Calibr_native
 USER_LIBR += mcufriend_blue_pill
## add ...


###: application directories, select or create, only one
### BlueVGA:
# APP_NAME = Elliptical_Text_Animation
# APP_NAME = graphDemo_SineCurve
# APP_NAME = hello_world
# APP_NAME = printTest
# APP_NAME = reading_joystick
# APP_NAME = scolling_text
# APP_NAME = simple_demo
# APP_NAME = snake_byte_game
# APP_NAME = Space_Invaders_Animation_Demo


# APP_NAME = aspect_blue_pill
# APP_NAME = blink
# APP_NAME = drawBitmap_kbv
# APP_NAME = graphictest_blue_pill # only for blue_pill board
# APP_NAME = graphictest_kbv
# APP_NAME = ommeter2
# APP_NAME = ommeter3
# APP_NAME = ommeter4
APP_NAME = ommeter5
# APP_NAME = readpixel_blue_pill
# APP_NAME = scroll_blue_pill
# APP_NAME = TouchScreen_Calibr_native
## add ...


# APPDIR = examples/blue_vga_examples/$(APP_NAME)
APPDIR = examples/$(APP_NAME)
## add ...


###: main file name of your sources
SRC := $(APPDIR)/$(APP_NAME).cpp

###: File name of generated binary to upload to Arduino
TARGET := uploadimg

### more libs: https://github.com/adafruit
