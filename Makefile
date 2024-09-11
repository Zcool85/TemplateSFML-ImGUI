default_target: all

.PHONY : default_target

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

SHELL       := /bin/sh

# Configure SFML
SFML_PATH    := /usr/local/Cellar/sfml/2.6.1
SFML_INC_DIR := $(SFML_PATH)/include
SFML_LIB_DIR := $(SFML_PATH)/lib


TARGET              := app

ENV                 := release
DEBUG_LEVEL         := 0
OPTIMIZATION_LEVEL  := 3
ifeq ($(DEBUG),yes)
ENV                 := debug
DEBUG_LEVEL         := 3
OPTIMIZATION_LEVEL  := 0
endif


CXX                 := clang++
SZ                  := size

SYS        := $(shell $(CXX) -dumpmachine)



CXXFLAGS    = -Wall -Wextra -Werror -Wpointer-arith -Wcast-qual \
              -Wno-missing-braces -Wempty-body -Wno-error=uninitialized \
              -Wno-error=deprecated-declarations \
              -pedantic-errors -pedantic
ifneq (, $(findstring darwin, $(SYS)))
CXXFLAGS   += -isysroot "$(shell xcode-select --print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
endif
CXXFLAGS   += -std=c++20
CXXFLAGS   += -O$(OPTIMIZATION_LEVEL)

CXXFLAGS   += -I $(SFML_INC_DIR)
CXXFLAGS   += -I ./src/imgui
CXXFLAGS   += -I ./src

ifeq ($(DEBUG),yes)
CXXFLAGS   += -g$(DEBUG_LEVEL)
endif




LD          = clang++ -o
LDFLAGS     = -Wall -pedantic
LDFLAGS    += -L$(SFML_LIB_DIR)
LDFLAGS    += -lsfml-graphics -lsfml-window -lsfml-system -lsfml-audio -lsfml-network
ifneq (, $(findstring linux, $(SYS)))
LDFLAGS    += -lGL
endif
ifneq (, $(findstring darwin, $(SYS)))
LDFLAGS    += -framework OpenGL
endif



SRCDIR      = src
OBJDIR      = obj
BINDIR      = bin

RM          = rm -f


#-------------------------------------------------------------------------------
# Get git version
#-------------------------------------------------------------------------------

ifneq ($(strip $(shell which git)),)
    GIT_REVISION  ?= $(shell git rev-parse HEAD)
else
    $(warning GIT command line tools cannot be found, cannot gather GIT commit sha1!)
    GIT_REVISION ?= 0
endif

DEFINES += -DSCM_REVISION=$(GIT_REVISION)


all: $(BINDIR)/$(ENV)/$(TARGET)

#-------------------------------------------------------------------------------
# Building rules for main cpp
#-------------------------------------------------------------------------------

SOURCES    := $(shell find -L "$(SRCDIR)" -type f -name "*.cpp" -print)
OBJECTS    := $(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/$(ENV)/%.o, $(SOURCES))
DEP_FILES  := $(patsubst $(OBJDIR)/$(ENV)/%.o,$(OBJDIR)/$(ENV)/%.d, $(OBJECTS))

-include $(DEP_FILES)

$(BINDIR)/$(ENV)/$(TARGET): $(OBJECTS) Makefile
	@mkdir -p $(@D)
	$(LD) $@ $(LDFLAGS) $(OBJECTS)
	@echo ""
	$(SZ) $(BINDIR)/$(ENV)/$(TARGET)
	@echo ""
	@echo ""
	@echo "------------ Executable info ------------"
	@printf "%-25s %s\n" "Full Path: "              "`realpath $(BINDIR)/$(ENV)/$(TARGET)`"
	@printf "%-25s %s\n" "Compiler:"                "`$(CXX) --version | head -1`"
	@printf "%-25s %s\n" "Target:"                  "`$(CXX) -dumpmachine`"
	@printf "%-25s %s\n" "Debug Level(0-3):"        "${DEBUG_LEVEL}"
	@printf "%-25s %s\n" "Optimization Level(0-3):" "${OPTIMIZATION_LEVEL}"
	@echo ""


$(OBJECTS): $(OBJDIR)/$(ENV)/%.o : $(SRCDIR)/%.cpp Makefile
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $(DEFINES) -MD -MP -c $< -o $@

#-------------------------------------------------------------------------------
# Building rules for clean
#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	@$(RM) $(OBJECTS) $(DEP_FILES)
	@echo "Cleanup complete!"

.PHONY: remove
remove: clean
	@$(RM) $(BINDIR)/$(ENV)/$(TARGET)
	@echo "Executable removed!"

#-------------------------------------------------------------------------------
# Formatage des fichiers
#-------------------------------------------------------------------------------

format:
	clang-format -i $(shell find $(SRCDIR) -name "*.cpp" -o -name "*.hpp" | grep -v "src/imgui")
