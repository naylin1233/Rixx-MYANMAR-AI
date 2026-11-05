# MYANMAR AI — New Project Starter

This is a clean Flutter starter with a Cloudflare Worker proxy for Gemini Interactions API.

## What is included now
- Flutter dark-green app shell
- AI Chat, translation, recap text, title/description/hashtag text, thumbnail copy ideas, and transcript-to-SRT assistance
- Cloudflare Worker proxy; API key stays on the server
- GitHub Actions APK build workflow

## Important feature status
This starter does **not** yet perform end-to-end video/audio processing, timed speech transcription, voice synthesis, actual image rendering, or video editing. Those require additional media-processing services and Android-side implementation. The SRT screen currently helps format supplied transcript text; it cannot infer accurate timestamps without audio/video transcription.

## Setup
1. Create a new Flutter project/repository and add these files.
2. Deploy `cloudflare-worker/worker.js` as a Cloudflare Worker.
3. In Cloudflare Worker Settings > Variables and Secrets, add `GEMINI_API_KEY` as a Secret. Never put the key in Flutter or GitHub.
4. Add a GitHub Actions repository secret named `WORKER_URL` with the deployed Worker URL.
5. In `lib/main.dart`, replace the default `workerUrl` with the Worker URL, or build with `--dart-define=WORKER_URL=...`.
6. Run `flutter pub get`, then build using `flutter build apk --release`.

## Budget and reliability
Gemini free-tier quotas and availability can change. HTTP 429 or high-demand responses mean the service is temporarily unavailable; retries cannot bypass quota limits. Review current pricing and quotas before enabling paid billing. Do not enable billing without explicit approval.

## API reference
The Worker uses the Gemini Interactions API with `gemini-3.8-flash`. See Google's current Interactions API documentation:
https://ai.google.dev/gemini-api/docs/interactions-overview
