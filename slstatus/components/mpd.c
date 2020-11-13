#include <err.h>
#include <stdio.h>
#include <string.h>

#include <mpd/client.h>

#include "../util.h"

/* fmt consist of lowercase :
 * "a" for artist,
 * "t" for song title,
 * "p" for time progression,
 * "at" for song artist then title
 * if not a, t or p, any character will be represented as separator.
 * i.e: "a-t" gives "artist-title"
*/
const char *
mpdonair(const char *fmt)
{
    static struct mpd_connection *conn; /* kept between calls */
    struct mpd_song *song = NULL;
    struct mpd_status *status = NULL;
	unsigned int elapsed = 0, total = 0;


	if (conn == NULL) {
		conn = mpd_connection_new(NULL, 0, 5000);
		if (conn == NULL) {
			warn("MPD error: %s",mpd_connection_get_error_message(conn));
			goto mpdout;
		}
	}

    mpd_send_status(conn);
	status = mpd_recv_status(conn);
	if (status == NULL) {
		goto mpdout;
	}

	if (mpd_status_get_state(status) == MPD_STATE_PLAY) {
		mpd_send_current_song(conn);
		song = mpd_recv_song(conn);
		if (song == NULL) {
			goto mpdout;
		}

		for (int i = 0; i < (int)strlen(fmt) ; i++) {
			switch (fmt[i]) {
			case 'a':
				bprintf("%s%s", buf, mpd_song_get_tag(song, MPD_TAG_ARTIST, 0));
				break;
			case 't':
				bprintf("%s%s", buf, mpd_song_get_tag(song, MPD_TAG_TITLE, 0));
				break;
			case 'p':
				elapsed = mpd_status_get_elapsed_ms(status)/1000;
				total = mpd_status_get_total_time(status);
				bprintf("%s%.2d:%.2d/%.2d:%.2d",
					buf,
					elapsed/60, elapsed%60,
					total/60, total%60);
				break;
			default:
				bprintf("%s%c", buf, fmt[i]);
				break;
			}
		}


		mpd_status_free(status);
		mpd_song_free(song);
		mpd_response_finish(conn);
		return(buf);
	}

mpdout:
	mpd_response_finish(conn);
	mpd_connection_free(conn);
	conn = NULL;
	return NULL;
}
