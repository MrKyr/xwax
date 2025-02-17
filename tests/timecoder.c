/*
 * Copyright (C) 2025 Mark Hills <mark@xwax.org>
 *
 * This file is part of "xwax".
 *
 * "xwax" is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License, version 3 as
 * published by the Free Software Foundation.
 *
 * "xwax" is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <https://www.gnu.org/licenses/>.
 *
 */

#include <assert.h>
#include <stdio.h>

#include "timecoder.h"

#define STEREO 2
#define RATE 96000
#define INTERVAL 4096

/*
 * Manual test of the timecoder's movement tracking. Read raw sample
 * information and write decoded pitch information.
 */

int main(int argc, char *argv[])
{
    unsigned int s;
    signed short sample[STEREO];
    struct timecoder tc;
    struct timecode_def *def;

    def = timecoder_find_definition("serato_2a");
    assert(def != NULL);

    timecoder_init(&tc, def, 1.0, RATE, false);

    s = 0;

    for(;;) {
        size_t z;

        z = fread(&sample, sizeof(short), STEREO, stdin);
        if (z != 2)
            break;

        timecoder_submit(&tc, sample, 1);

        if (s % (RATE / INTERVAL) == 0) {
            float pitch;

            pitch = timecoder_get_pitch(&tc);
            printf("%f\t%.12f\n",
                   (float)s / RATE, pitch);
        }

        s++;
    }

    fflush(stdout);

    timecoder_clear(&tc);
    timecoder_free_lookup();

    return 0;
}
