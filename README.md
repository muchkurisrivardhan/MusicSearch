# MusicSearch

iOS app: search bar over archive.org's audio collection, results list.
No dependencies, no API key.

## Install on iPhone (no Mac)

1. Push this repo to GitHub.
2. **Actions** tab -> "Build iOS IPA" -> **Run workflow**. Takes ~3 min.
3. Download the `MusicSearch-ipa` artifact, unzip -> `MusicSearch.ipa`.
4. Install [Sideloadly](https://sideloadly.io) on Windows, plus Apple's
   **Devices** app (from apple.com, NOT the Microsoft Store build).
5. Plug in the iPhone, tap Trust. Drag the IPA into Sideloadly, enter your
   Apple ID, Start.
6. On the phone: Settings -> General -> VPN & Device Management -> trust the
   developer certificate. Then open the app.

**A free Apple ID cert lasts 7 days.** Re-run step 5 to renew, or use AltStore
to auto-renew over Wi-Fi. A paid account ($99/yr) lasts a year.

## Install on iPhone (with a Mac)

Open in Xcode, select your phone, hit Run. Skip everything above.

## Check

`python check_api_shape.py` - verifies archive.org's JSON still matches what
`Track`'s decoder expects. Run it if results come back blank.

## Not built yet

Playback, offline download, Pi-side service. Search only.
