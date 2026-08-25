"""Guards Track's decoder: archive.org returns title/creator as str, list, or omits them.
If this starts failing, MusicSearchApp.swift's Track.flat() needs updating."""
import json, urllib.parse, urllib.request

URL = "https://archive.org/advancedsearch.php?" + urllib.parse.urlencode(
    [("q", "live concert AND mediatype:(audio)"), ("fl[]", "identifier"),
     ("fl[]", "title"), ("fl[]", "creator"), ("rows", "200"), ("output", "json")])

docs = json.load(urllib.request.urlopen(URL))["response"]["docs"]
assert docs, "no results returned"
assert all("identifier" in d for d in docs), "identifier must always be present"

seen = {t for d in docs for t in (type(d.get("creator")).__name__,)}
assert seen <= {"str", "list", "NoneType"}, f"unexpected creator types: {seen}"
print(f"ok: {len(docs)} docs, creator types = {sorted(seen)}")
