include /f-of-e-tools/tools/sunflower/conf/setup.conf

TREEROOT = $(SUNFLOWERROOT)
GB3_ROOT = /gb3-resources

TARGET-ARCH	= riscv32-elf
TARGET		= riscv

PROGRAM		= bubblesort
PROGRAM-SF	= bubblesort-sf
INIT		= init
INIT-SF		= init-sf

INCLUDE_DIR = ../include

OPTFLAGS	= -O0
CFLAGS		= -march=rv32i -mabi=ilp32 $(TARGET-ARCH-FLAGS) -Wall
ASFLAGS		= --march=rv32i --mabi=ilp32
INCLUDES	= -I$(INCLUDE_DIR)
LDFLAGS		= -L$(TOOLSLIB)/$(TARGET) -Map $(PROGRAM).map -Tsail.ld
LDFLAGS-SF	= -Ttext $(LOADADDR-SF)  -L$(TOOLSLIB)/$(TARGET) -Map $(PROGRAM).map
SREC2HEX	= srec2hex
LOADADDR-SF	= 0x08004000

OBJS		=\
		$(INIT).o\
		$(PROGRAM).o\

OBJS-SF		=\
		$(INIT-SF).o\
		$(PROGRAM).o\

all:	$(PROGRAM) $(PROGRAM).sr $(PROGRAM-SF) $(PROGRAM-SF).sr Makefile

$(INIT).o: $(INIT).S
	$(AS) $(ASFLAGS) $(INIT).S -o $(INIT).o

$(PROGRAM): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lc -lm -lgcc

$(PROGRAM).sr:$(PROGRAM)
	$(OBJCOPY) -O srec $(PROGRAM) $@

$(PROGRAM).o: $(PROGRAM).c Makefile
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $(PROGRAM).c


$(INIT-SF).o: $(INIT-SF).S
	$(CPP) $(INIT-SF).S > $(INIT-SF).i; $(AS) $(ASFLAGS) $(INIT-SF).i -o $(INIT-SF).o

$(PROGRAM-SF): $(OBJS-SF)
	$(LD) $(LDFLAGS-SF) $(OBJS-SF) -o $@ -lc -lgcc -lgloss

$(PROGRAM-SF).sr:$(PROGRAM-SF)
	$(OBJCOPY) -O srec $(PROGRAM-SF) $@

install: all
	mkdir -p $(GB3_ROOT)/processor/programs/
	$(SREC2HEX) -b 4096 $(PROGRAM).sr
	cp program.hex $(GB3_ROOT)/processor/programs/
	cp data.hex $(GB3_ROOT)/processor/programs/

clean:
	$(RM) init.i *.o $(PROGRAM) $(PROGRAM).sr $(PROGRAM).map
	$(RM) init-sf.i *.o $(PROGRAM-SF) $(PROGRAM-SF).sr $(PROGRAM-SF).map
	$(RM) program.hex data.hex
