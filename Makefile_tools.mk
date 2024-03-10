
DISTRO = ./distro

# Change them where Arduino IDE is installed
ARM_GCC_PATH = /usr/bin
# ARM_GCC_PATH := $(DISTRO)/gcc-arm-none-eabi-8.2.1-1.7/bin

ARDUINO_DIR = $(DISTRO)/Arduino_Core_STM32
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/cores/arduino
ARDUINO_VAR_PATH ?= $(ARDUINO_DIR)/variants
TOOLS_DIR = $(DISTRO)
CMSIS_DIR = $(DISTRO)/ArduinoModule-CMSIS/CMSIS

MASS_TOOL := $(TOOLS_DIR)/STM32Tools/1.4.0/tools/linux/massStorageCopy.sh
