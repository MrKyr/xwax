# Copyright (C) 2012 Mark Hills <mark@pogo.org.uk>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License version 2 for more details.
# 
# You should have received a copy of the GNU General Public License
# version 2 along with this program; if not, write to the Free
# Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#

INSTALL = install

PREFIX = $(HOME)

CFLAGS += -Wall -O3
CPPFLAGS += -MMD
LDFLAGS += -O3

SDL_CFLAGS = `sdl-config --cflags`
SDL_LIBS = `sdl-config --libs` -lSDL_ttf
ALSA_LIBS = -lasound
JACK_LIBS = -ljack

# Import the optional configuration

-include .config

# Installation paths

BINDIR = $(PREFIX)/bin
EXECDIR = $(PREFIX)/libexec
MANDIR = $(PREFIX)/share/man
DOCDIR = $(PREFIX)/share/doc

# Core objects and libraries

OBJS = controller.o cues.o deck.o device.o external.o import.o interface.o \
	library.o listing.o lut.o \
	player.o realtime.o \
	rig.o selector.o timecoder.o track.o xwax.o
DEVICE_CPPFLAGS =
DEVICE_LIBS =

# Optional device types

ifdef ALSA
OBJS += alsa.o dicer.o midi.o
DEVICE_CPPFLAGS += -DWITH_ALSA
DEVICE_LIBS += $(ALSA_LIBS)
endif

ifdef JACK
OBJS += jack.o
DEVICE_CPPFLAGS += -DWITH_JACK
DEVICE_LIBS += $(JACK_LIBS)
endif

ifdef OSS
OBJS += oss.o
DEVICE_CPPFLAGS += -DWITH_OSS
endif

DEPS = $(OBJS:.o=.d)

# Rules

.PHONY:		all clean install

all:		xwax

# Dynamic versioning

.PHONY:		FORCE

.version:	FORCE
		./mkversion -r

VERSION = $(shell ./mkversion)

# Main binary

xwax:		$(OBJS)
xwax:		LDLIBS += $(SDL_LIBS) $(DEVICE_LIBS) -lm
xwax:		LDFLAGS += -pthread

interface.o:	CFLAGS += $(SDL_CFLAGS)

xwax.o:		CFLAGS += $(SDL_CFLAGS) $(DEVICE_CPPFLAGS)
xwax.o:		CPPFLAGS += -DEXECDIR=\"$(EXECDIR)\" -DVERSION=\"$(VERSION)\"
xwax.o:		.version

# Install to system

install:
		$(INSTALL) -d $(BINDIR)
		$(INSTALL) xwax $(BINDIR)/xwax
		$(INSTALL) -d $(EXECDIR)
		$(INSTALL) scan $(EXECDIR)/xwax-scan
		$(INSTALL) import $(EXECDIR)/xwax-import
		$(INSTALL) -d $(MANDIR)/man1
		$(INSTALL) -m 0644 xwax.1 $(MANDIR)/man1/xwax.1
		$(INSTALL) -d $(DOCDIR)/xwax
		$(INSTALL) -m 0644 CHANGES $(DOCDIR)/xwax/CHANGES
		$(INSTALL) -m 0644 COPYING $(DOCDIR)/xwax/COPYING
		$(INSTALL) -m 0644 README $(DOCDIR)/xwax/README

# Distribution archive from Git source code

.PHONY:		dist

dist:		.version
		./mkdist $(VERSION)

# Manual tests

.PHONY:		tests

tests:		test-cues test-library test-timecoder test-track

test-cues:	test-cues.o cues.o

test-library:	test-library.o external.o library.o listing.o

test-midi:	test-midi.o midi.o
test-midi:	LDLIBS += $(ALSA_LIBS)

test-timecoder:	test-timecoder.o lut.o timecoder.o

test-track:	test-track.o external.o import.o rig.o track.o
# FIXME: Test requires rt_not_allowed() which should not bring in
# all the dependencies below
test-track:	realtime.o controller.o device.o lut.o player.o timecoder.o
test-track:	LDFLAGS += -pthread
test-track:	LDLIBS += -lm

clean:
		rm -f xwax \
			test-cues \
			test-library \
			test-midi \
			test-timecoder \
			test-track \
			$(OBJS) $(DEPS)

-include $(DEPS)
