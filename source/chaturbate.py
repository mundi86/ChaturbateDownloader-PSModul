"""
Chaturbate plugin for Streamlink.

Extracts HLS streams from Chaturbate live broadcasts.

Compatible with Streamlink 1.7.0+
"""

import logging
import re
import uuid

from streamlink.plugin import Plugin
from streamlink.plugin.api import http, validate
from streamlink.stream import HLSStream

log = logging.getLogger(__name__)

API_HLS = "https://chaturbate.com/get_edge_hls_url_ajax/"

_url_re = re.compile(r"https?://(\w+\.)?chaturbate\.com/(?P<username>\w+)")

_post_schema = validate.Schema(
    {
        "url": validate.text,
        "room_status": validate.text,
        "success": int,
    }
)

ROOM_STATUSES = {
    "public":      "Stream is public and live ✔",
    "private":     "Stream is in a private show",
    "away":        "Broadcaster is away",
    "offline":     "Broadcaster is offline",
    "hidden":      "Stream is hidden",
    "password protected": "Stream is password protected",
}


class Chaturbate(Plugin):
    """Streamlink plugin for Chaturbate."""

    @classmethod
    def can_handle_url(cls, url):
        return _url_re.match(url) is not None

    def _get_streams(self):
        match = _url_re.match(self.url)
        if not match:
            log.error("Invalid Chaturbate URL: %s", self.url)
            return

        username = match.group("username")
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

        post_data = "room_slug={0}&bandwidth=high".format(username)

        try:
            res  = http.post(API_HLS, headers=headers, cookies=cookies, data=post_data)
            data = http.json(res, schema=_post_schema)
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
            for name, stream in streams.items():
                yield name, stream
        except Exception as exc:
            log.error("Failed to parse HLS playlist: %s", exc)


__plugin__ = Chaturbate
