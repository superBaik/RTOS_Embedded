ARCH = armv7-a # 아키텍처 정보
MCPU = cortex-a8 # cpu 정보 => 둘 다 39번줄에서 사용

TARGET = rvpb

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy # => 모두 크로스컴파일러 실행파일의 이름, 일명 '툴체인'

LINKER_SCRIPT = ./navilos.ld # 링커스크립트의 이름
MAP_FILE = build/navilos.map

ASM_SRCS = $(wildcard boot/*.S) # make의 빌트인 함수: "boot 디렉터리에서 .S는 전부 ASM_SRCS 변수에 값으로 넣으라", 즉 boot/Entry.S 저장
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS)) # make의 빌트인 함수: "boot 디렉터리에서 .S를 찾아 전부 .o로 바꾸고 디렉터리도 build로 바꿔 ASM_OBJS 변수에 값으로 넣어라", 즉 build/Entry.o 저장

VPATH = boot \
		hal/$(TARGET) \
		lib

C_SRCS  = $(notdir $(wildcard boot/*.c))
C_SRCS += $(notdir $(wildcard ./hal/$(TARGET)/*.c))
C_SRCS += $(notdir $(wildcard lib/*.c))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS)) 

INC_DIRS  = -I include 			\
            -I hal	   			\
            -I hal/$(TARGET)	\
			-I lib
            
CFLAGS = -c -g -std=c11 

LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

navilos = build/navilos.axf # 최종 ELF명
navilos_bin = build/navilos.bin # 최종 바이너리 파일명

.PHONY: all clean run debug gdb

all: $(navilos)

clean: 
	@rm -fr build

run: $(navilos) # 실행 명령어. 매번 타이핑 귀찮으니까.
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -nographic
debug: $(navilos) # qemu와 gdb 연결
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -S -gdb tcp::1234,ipv4

gdb: # 마찬가지로 gdb 실행 자동화
	arm-none-eabi-gdb

$(navilos): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT) # 링커로써, axf 파일 생성 및 bin 생성
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(navilos) $(navilos_bin)

build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<

build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) $(INC_DIRS) $(CFLAGS) -o $@ $<
