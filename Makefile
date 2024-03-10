
# Adjust for your board
# Manually add them which Arduino IDE gives automotically
# select you board in file: Makefile_user.mk

include Makefile_tools.mk
include Makefile_user.mk

ELF    := $(TARGET).elf
BIN    := $(TARGET).bin
HEX    := $(TARGET).hex

# Only have to edit above files: Makefile_board_*.mk and Makefile_usrlib.mk
#############################################################################
# Others below are for building and linking libraries automatically.
#SHELL = /bin/bash -xue

OBJDIR = objects
CORE_LIB = $(OBJDIR)/libcore.a

CC := $(ARM_GCC_PATH)/arm-none-eabi-gcc 
CXX := $(ARM_GCC_PATH)/arm-none-eabi-g++
OBJCOPY := $(ARM_GCC_PATH)/arm-none-eabi-objcopy
AR := $(ARM_GCC_PATH)/arm-none-eabi-gcc-ar
SZ := $(ARM_GCC_PATH)/arm-none-eabi-size


all: $(CORE_LIB) $(ELF) $(BIN) $(HEX)

GCCFLAGS  = -ffunction-sections
GCCFLAGS += -fdata-sections
GCCFLAGS += -nostdlib
GCCFLAGS += -fno-threadsafe-statics
GCCFLAGS += --param max-inline-insns-single=500
GCCFLAGS += -fno-rtti
GCCFLAGS += -fno-exceptions
GCCFLAGS += -fno-use-cxa-atexit

CFLAGS_STD = -c -Os -w -std=gnu17 $(GCCFLAGS)
CXXFLAGS_STD = -c -Os -w -std=gnu++17 $(GCCFLAGS)

LOCAL_C_SRCS    ?= $(wildcard $(APPDIR)/*.c)
LOCAL_CPP_SRCS  ?= $(wildcard $(APPDIR)/*.cpp)
LOCAL_CC_SRCS   ?= $(wildcard $(APPDIR)/*.cc)
LOCAL_PDE_SRCS  ?= $(wildcard $(APPDIR)/*.pde)
LOCAL_INO_SRCS  ?= $(wildcard $(APPDIR)/*.ino)
LOCAL_AS_SRCS   ?= $(wildcard $(APPDIR)/*.S)

LOCAL_SRCS = \
	$(LOCAL_C_SRCS) \
	$(LOCAL_CPP_SRCS) \
	$(LOCAL_CC_SRCS) \
	$(LOCAL_PDE_SRCS) \
	$(LOCAL_INO_SRCS) \
	$(LOCAL_AS_SRCS)

ARDUINO_LIB_PATH = $(ARDUINO_DIR)/libraries
STM32_HAL_PATH   = $(ARDUINO_DIR)/system

ARDUINO_LIBR += \
	$(filter $(notdir $(wildcard $(ARDUINO_LIB_PATH)/*)), \
	$(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))

USER_LIBS += \
	$(filter $(notdir $(wildcard $(USER_LIB_PATH)/*)), \
	$(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))

USER_LIBS += $(sort $(wildcard $(patsubst %,$(USER_LIB_PATH)/%,$(USER_LIBR))))

SYS_LIBS  := $(sort $(wildcard $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(ARDUINO_LIBR))))

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

get_library_includes = \
	$(if $(wildcard $(1)/src), \
	-I $(1)/src, \
	$(addprefix -I ,$(1) $(wildcard $(1)/utility)))

SYS_INCLUDES  := $(foreach lib, $(SYS_LIBS),  $(call get_library_includes,$(lib)))
SYS_INCLUDES  += -I $(ARDUINO_CORE_PATH)/stm32
USER_INCLUDES := $(foreach lib, $(USER_LIBS), $(call get_library_includes,$(lib)))

HAL_LIB_PATH  = $(ARDUINO_DIR)/libraries/SrcWrapper/src
HAL_DRV_PATH  = $(STM32_HAL_PATH)/Drivers/$(HAL_SRC)_HAL_Driver/Src
HAL_PATH      = $(HAL_LIB_PATH) $(HAL_DRV_PATH)

HAL_C_SRCS    += $(call rwildcard ,$(HAL_LIB_PATH),*.c)
HAL_CPP_SRCS  += $(call rwildcard ,$(HAL_LIB_PATH),*.cpp)
HAL_AS_SRCS   += $(call rwildcard ,$(HAL_LIB_PATH),*.S)
DRV_C_SRCS    += $(call rwildcard ,$(HAL_DRV_PATH),*.c)
VAL_C_SRCS    += $(call rwildcard ,$(ARDUINO_VAR_PATH)/$(VARIANT),*.c)
VAL_CPP_SRCS  += $(call rwildcard ,$(ARDUINO_VAR_PATH)/$(VARIANT),*.cpp)

HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Drivers/$(HAL_SRC)_HAL_Driver/Inc
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Drivers/$(HAL_SRC)_HAL_Driver/Src
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/$(HAL_SRC)
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Drivers/CMSIS/Device/ST/$(HAL_SRC)/Include
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Drivers/CMSIS/Device/ST/$(HAL_SRC)/Source/Templates/gcc
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/ST/STM32_USB_Device_Library/Core/Inc
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/ST/STM32_USB_Device_Library/Cort/Src
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/OpenAMP
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/OpenAMP/open-amp/lib/include
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/OpenAMP/libmetal/lib/include
HAL_INCLUDES  += -I $(STM32_HAL_PATH)/Middlewares/OpenAMP/virtual_driver

HAL_OBJ_FILES  = $(HAL_C_SRCS:.c=.c.o) $(HAL_CPP_SRCS:.cpp=.cpp.o) $(HAL_AS_SRCS:.S=.S.o)
DRV_OBJ_FILES  = $(DRV_C_SRCS:.c=.c.o) $(DRV_CPP_SRCS:.cpp=.cpp.o) $(DRV_AS_SRCS:.S=.S.o)
VAL_OBJ_FILES  = $(VAL_C_SRCS:.c=.c.o) $(VAL_CPP_SRCS:.cpp=.cpp.o) $(VAL_AS_SRCS:.S=.S.o)

CORE_C_SRCS    = $(call rwildcard ,$(ARDUINO_CORE_PATH),*.c)
CORE_CPP_SRCS  = $(call rwildcard ,$(ARDUINO_CORE_PATH),*.cpp)
CORE_AS_SRCS   = $(call rwildcard ,$(ARDUINO_CORE_PATH),*.S)

CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/avr
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32/LL
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32/usb
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32/OpenAMP
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32/usb/hid
CORE_INCLUDES += -I $(ARDUINO_CORE_PATH)/stm32/usb/cdc

TOOL_INC_PATH  = -I $(CMSIS_DIR)/CMSIS/Include
TOOL_INC_PATH += -I $(CMSIS_DIR)/CMSIS/DSP/Include

INCLUDES  = $(ARD_CFLAGS)
INCLUDES += $(CORE_INCLUDES)
INCLUDES += $(SYS_INCLUDES)
INCLUDES += $(HAL_INCLUDES)
INCLUDES += $(TOOL_INC_PATH)
INCLUDES += $(USER_INCLUDES)
INCLUDES += -I $(ARDUINO_VAR_PATH)/$(VARIANT)

CPPFLAGS += $(ISAFLAGS) $(INCLUDES)

CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS_SRCS:.S=.S.o)

MKDIR   = mkdir --parent

## shell color ##
green=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m
##-------------##

$(OBJDIR)/%.c.o: $(ARDUINO_CORE_PATH)/%.c $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/%.c.o: $(ARDUINO_VAR_PATH)/$(VARIANT)/%.c $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/%.cpp.o: $(ARDUINO_CORE_PATH)/%.cpp $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS_STD) $< -o $@

$(OBJDIR)/%.cpp.o: $(ARDUINO_VAR_PATH)/$(VARIANT)/%.cpp $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS_STD) $< -o $@

$(OBJDIR)/%.S.o: $(ARDUINO_CORE_PATH)/%.S $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

VAL_OBJS = $(patsubst $(ARDUINO_VAR_PATH)/$(VARIANT)/%, $(OBJDIR)/%,$(VAL_OBJ_FILES))
CORE_OBJS = $(patsubst $(ARDUINO_CORE_PATH)/%, $(OBJDIR)/%,$(CORE_OBJ_FILES))

$(OBJDIR)/hal/%.c.o: $(HAL_LIB_PATH)/%.c $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/hal/%.c.o: $(HAL_DRV_PATH)/%.c $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/hal/%.cpp.o: $(HAL_LIB_PATH)/%.cpp $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS_STD) $< -o $@

$(OBJDIR)/hal/%.S.o: $(HAL_LIB_PATH)/%.S $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

HAL_OBJS = $(patsubst $(HAL_LIB_PATH)/%, $(OBJDIR)/hal/%,$(HAL_OBJ_FILES))
DRV_OBJS = $(patsubst $(HAL_DRV_PATH)/%, $(OBJDIR)/hal/%,$(DRV_OBJ_FILE))

get_library_files = \
	$(if $(wildcard $(1)/src), \
	$(call rwildcard,$(1)/src/,*.$(2)), \
	$(wildcard $(1)/*.$(2) $(1)/utility/*.$(2)))

LIB_C_SRCS          := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),c))
LIB_CPP_SRCS        := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),cpp))
LIB_AS_SRCS         := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),S))
USER_LIB_CPP_SRCS   := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),cpp))
USER_LIB_C_SRCS     := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),c))
USER_LIB_AS_SRCS    := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),S))

LIB_OBJS = \
	$(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(LIB_CPP_SRCS)) \
	$(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(LIB_C_SRCS)) \
	$(patsubst $(ARDUINO_LIB_PATH)/%.S,$(OBJDIR)/libs/%.S.o,$(LIB_AS_SRCS))

USER_LIB_OBJS = \
	$(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/userlibs/%.cpp.o,$(USER_LIB_CPP_SRCS)) \
	$(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/userlibs/%.c.o,$(USER_LIB_C_SRCS)) \
	$(patsubst $(USER_LIB_PATH)/%.S,$(OBJDIR)/userlibs/%.S.o,$(USER_LIB_AS_SRCS))

$(OBJDIR)/libs/%.c.o: $(ARDUINO_LIB_PATH)/%.c $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/libs/%.cpp.o: $(ARDUINO_LIB_PATH)/%.cpp $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS_STD) $< -o $@

$(OBJDIR)/libs/%.S.o: $(ARDUINO_LIB_PATH)/%.S $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.c.o: $(USER_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS_STD) $< -o $@

$(OBJDIR)/userlibs/%.cpp.o: $(USER_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS_STD) $< -o $@

$(OBJDIR)/userlibs/%.S.o: $(USER_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	@echo "\n ${green} [compile:] ${YELLOW} $< ${NC}"
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

LDFLAGS += $(ISAFLAGS)
LDFLAGS += --specs=nano.specs
LDFLAGS += -Wl,--defsym=LD_FLASH_OFFSET=0
LDFLAGS += -Wl,--defsym=LD_MAX_SIZE=$(FLASH_SIZE)
LDFLAGS += -Wl,--defsym=LD_MAX_DATA_SIZE=$(RAM_SIZE)
LDFLAGS += -Wl,-gc-sections,--print-memory-usage,-Map=$(TARGET).map
LDFLAGS += -Wl,--check-sections
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -Wl,--entry=Reset_Handler
LDFLAGS += -Wl,--unresolved-symbols=report-all
LDFLAGS += -Wl,--warn-common
LDFLAGS += -Wl,--default-script=$(ARDUINO_DIR)/variants/$(VARIANT)/ldscript.ld
LDFLAGS += -Wl,--script=$(ARDUINO_DIR)/system/ldscript.ld
LDFLAGS += -L -lm
LDFLAGS += -Wl,--start-group
LDFLAGS += -lgcc
LDFLAGS += -lstdc++
LDFLAGS += -lc

$(CORE_LIB): $(VAL_OBJS) $(CORE_OBJS) $(HAL_OBJS) $(DRV_OBJS) $(LIB_OBJS) $(USER_LIB_OBJS)
	@echo "\n ${green} [archive:] ${YELLOW} $@ ${NC}"
	$(AR) rcs $@ $^

# Building arduino binary image

$(ELF): $(SRC) $(CORE_LIB)
	@echo "\n ${green} [linking:] ${YELLOW} $@ ${NC}"
	$(CC) $(INCLUDES) $(LDFLAGS) $^ -Wl,--end-group -o $@
	$(SZ) --format=GNU -d $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(HEX): $(ELF)
	$(OBJCOPY) -O ihex -R .eeprom $< $@

upload-mass: $(BIN)
	$(MASS_TOOL) -I $< $(MASS_OPTION)

flash:
	@echo -e "\n\033[0;32m[Flashing]\033[0m"
	@openocd \
	-f interface/$(OPENOCD_INTERFACE).cfg \
	-f target/$(OPENOCD_TARGET).cfg \
	-c "program $(ELF) verify" \
	-c "reset" \
	-c "exit"

burn:
	st-flash write $(BIN) 0x08000000

clean:
	rm -fr $(BIN) $(ELF) $(HEX) $(TARGET).map $(CORE_LIB) $(OBJDIR)

cleanuser:
	rm -fr $(BIN) $(ELF) $(HEX) $(TARGET).map $(OBJDIR)/userlibs
