# Compiler and flags
CC = gcc
CFLAGS = -Wall -fPIC -I. -I./pm3 -I./hardnested
LDFLAGS = -static -llzma -lpthread -lm

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
# macOS has no static libc and no separate liblzma; pull it from Homebrew
# and drop -static (fully static binaries aren't supported on macOS).
BREW_XZ_PREFIX := $(shell brew --prefix xz 2>/dev/null)
CFLAGS += -I$(BREW_XZ_PREFIX)/include
LDFLAGS = -L$(BREW_XZ_PREFIX)/lib -llzma -lpthread -lm
endif

HARDNESTED_DIR = .

# Source files
HARDNESTED_SOURCES = $(HARDNESTED_DIR)/pm3/ui.c $(HARDNESTED_DIR)/pm3/util.c \
                     $(HARDNESTED_DIR)/cmdhfmfhard.c $(HARDNESTED_DIR)/pm3/commonutil.c \
                     $(HARDNESTED_DIR)/crapto1.c $(HARDNESTED_DIR)/crypto1.c \
                     $(HARDNESTED_DIR)/hardnested/hardnested_bf_core.c \
                     $(HARDNESTED_DIR)/hardnested/hardnested_bruteforce.c \
                     $(HARDNESTED_DIR)/hardnested/hardnested_bitarray_core.c \
                     $(HARDNESTED_DIR)/hardnested/tables.c \
                     $(HARDNESTED_DIR)/pm3/util_posix.c

# Object files
HARDNESTED_OBJECTS = $(HARDNESTED_SOURCES:.c=.o)

# Dependency files
HARDNESTED_DEPS = $(HARDNESTED_SOURCES:.c=.d)

# Executable target
EXECUTABLE = hardnested_main

# Targets
all: $(EXECUTABLE)

$(EXECUTABLE): hardnested_main.c $(HARDNESTED_OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(HARDNESTED_OBJECTS) $(HARDNESTED_DEPS) $(EXECUTABLE)

.PHONY: all clean

# Include dependencies
-include $(HARDNESTED_OBJECTS:.o=.d)

# Generate dependencies
%.d: %.c
	@$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
