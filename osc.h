/*
 * Copyright (C) 2012 Mark Hills <mark@pogo.org.uk>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License version 2 for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 2 along with this program; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */

/*
 * Functions for external control via a socket
 */

#ifndef OSC_H
#define OSC_H

#include <poll.h>
#include <stdlib.h>

#include <lo/lo.h>

#include "list.h"
#include "library.h"
#include "deck.h"

void error(int num, const char *m, const char *path);

int generic_handler(const char *path, const char *types, lo_arg ** argv,
                    int argc, void *data, void *user_data);
int load_track_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int get_status_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int get_monitor_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int recue_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int disconnect_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int reconnect_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);
int quit_handler(const char *path, const char *types, lo_arg ** argv,
                int argc, void *data, void *user_data);

int osc_start(struct deck *deck, struct library *library, size_t ndeck);
void osc_stop();

int osc_send_status(lo_address a, int d);
int osc_send_monitor(lo_address a, int d);


#endif
