# Diktafon — Privacy Policy

_Effective date: 1 October 2026_

Diktafon ("the app") is a voice-memo app developed by Jaromír Janisch
("the developer"). This policy explains what data the app handles and what
happens to it.

**The short version: everything stays on your device unless you explicitly
choose otherwise. Without your consent, the app uploads nothing, collects
nothing and shares nothing.**

## Data the app stores — on your device only

- Voice recordings you make.
- Transcripts and summaries the app derives from those recordings.
- Cassette labels and app settings.

All of this lives in the app's private storage on your device.
Transcription (whisper.cpp) and summarisation (llama.cpp) run entirely
on-device. Without your explicit opt-in (see the fork note below), no
recording, transcript, summary, or any other user data is ever transmitted
off your device by the app.

## No data collection or sharing

- The app has no user accounts, no analytics, no crash reporting, no
  advertising, and no third-party service SDKs.
- The developer receives no data of any kind from the app.

## Network use

The app's only network activity is downloading machine-learning model
files over HTTPS from Hugging Face (`huggingface.co` and its CDN), at your
explicit request. These downloads carry no personal data, identifiers, or
telemetry from the app. As with any web request, the server can see your
IP address; see the [Hugging Face privacy
policy](https://huggingface.co/privacy) for how they handle requests.
By default, nothing is ever uploaded.

## Permissions

- **Microphone** (`RECORD_AUDIO`) — recording voice memos; requested when
  you first press record. Audio is captured only while you are recording.
- **Internet** — model downloads from Hugging Face only.
- **Notifications** (`POST_NOTIFICATIONS`) — model-download progress;
  requested on Android 13+.

## Backups and export

- **Android Auto Backup** may include the app's database (labels,
  transcripts, summaries — not audio recordings, not models) in your own
  Google-account device backup. That backup is encrypted, controlled by
  you, and inaccessible to the developer.
- **Export** — you can export a cassette to a `.zip` archive saved to a
  location you choose. This is a local file operation on your device;
  what you do with the archive afterwards is up to you.

## Data retention and deletion

Your data exists only on your device. Deleting a memo or cassette in the
app removes its audio and derived text immediately; uninstalling the app
removes everything.

## Children

The app is not directed at children and collects no data from anyone.

## Changes to this policy

Any changes will be published at this URL with an updated effective date.

## Contact

Jaromír Janisch — author@jaromiru.com — or open an issue at
<https://github.com/jaromiru/diktafon>.

---

## Fork note — opt-in cloud backup and cloud transcription

This fork adds two **optional, off-by-default** features that send data to
a server **you** configure: automatic upload of finished memos, and
transcription by your own cloud backend. Everything above still applies
while both stay disabled — the app's network behaviour is then unchanged:
model downloads only, nothing uploaded.

If you explicitly enable them in Settings:

- **Cloud backup** (`Automatic backup`): after a memo's recording is
  finalized and its on-device transcription completes, the app sends
  **to the URL you entered** — and nowhere else — the finalized audio
  file, the local Whisper transcript (structured JSON) and a small
  metadata manifest (memo id, timestamps, duration, language, audio
  format and size, app version).
- **Cloud transcription**: if you switch the transcription mode to
  `In cloud`, or explicitly consent per memo after a failed local
  transcription attempt, the memo's audio is sent **to the URL you
  entered** — and nowhere else — so a backend you control can transcribe
  it. The returned transcript is stored locally like any on-device
  transcript. Local recordings are never deleted by either feature.
- The access token you enter is kept in the operating system's secure
  credential store (Android Keystore), never in the app's database, and is
  sent only as an Authorization header to your own server.
- Uploads happen over HTTPS (plain HTTP works only as an explicit
  local-development escape hatch). Upload retries are automatic; your
  local recordings and transcripts are never deleted by these features.
- There is still no account, no analytics, and no telemetry to the fork's
  authors: the only added network destination is the one you type in.

Server-side handling of the uploaded data is governed by the server you
chose, outside the scope of this document.

