"""
$description Chaturbate live-stream plugin.
$url chaturbate.com
$type live
"""

import re
import uuid

from streamlink.logger import getLogger
from streamlink.plugin import Plugin, pluginmatcher
from streamlink.plugin.api import validate
from streamlink.stream.hls import HLSStream

log = getLogger(__name__)

API_HLS = "https://chaturbate.com/get_edge_hls_url_ajax/"

_url_re = re.compile(r"https?://(?:\w+\.)?chaturbate\.com/(?P<username>\w+)/?$")

_post_schema = validate.Schema(
    {
        "url": validate.any("", validate.url()),
        "room_status": str,
        "success": int,
    },
)

ROOM_STATUSES = {
    "public":      "Stream is public and live ✔",
    "private":     "Stream is in a private show",
    "away":        "Broadcaster is away",
    "offline":     "Broadcaster is offline",
    "hidden":      "Stream is hidden",
    "password protected": "Stream is password protected",
}


@pluginmatcher(_url_re)
class Chaturbate(Plugin):
    """Streamlink plugin for Chaturbate."""

    def _get_streams(self):
        username = self.match.group("username")
        log.info("Fetching stream for user: %s", username)

        csrf_token = str(uuid.uuid4().hex.upper()[:32])

        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "X-CSRFToken": csrf_token,
            "X-Requested-With": "XMLHttpRequest",
            "Referer": self.url,
        }

        cookies = {
            "csrftoken": csrf_token,
        }

        post_data = {
            "room_slug": username,
            "bandwidth": "high",
        }

        try:
            res = self.session.http.post(
                API_HLS,
                headers=headers,
                cookies=cookies,
                data=post_data,
            )
            data = self.session.http.json(res, schema=_post_schema)
        except Exception as exc:
            log.error("Failed to fetch stream data from API: %s", exc)
            return

        room_status = data.get("room_status", "unknown")
        status_msg  = ROOM_STATUSES.get(room_status, "Unknown status: {0}".format(room_status))
        log.info("Room status: %s — %s", room_status, status_msg)

        if room_status != "public":
            log.warning(
                "Stream for '%s' is not public (status: %s). No streams available.",
                username,
                room_status,
            )
            return

        if not data.get("success"):
            log.error("API reported failure for user '%s'.", username)
            return

        stream_url = data.get("url", "").strip()
        if not stream_url:
            log.error("API returned an empty stream URL for user '%s'.", username)
            return

        log.debug("Stream URL: %s", stream_url)

        try:
            streams = HLSStream.parse_variant_playlist(self.session, stream_url)
            if not streams:
                log.warning("No HLS streams found in playlist for '%s'.", username)
                return
            yield from streams.items()
        except Exception as exc:
            log.error("Failed to parse HLS playlist: %s", exc)


__plugin__ = Chaturbate
