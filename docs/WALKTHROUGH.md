# iOS walkthrough

The delivered `artifacts/ios-walkthrough.mp4` is a **5 minute 26 second silent recording of the real iPhone simulator**. Idle pauses are trimmed; the original uncut recording is retained locally as `artifacts/ios-walkthrough-raw.mp4`. It shows live feeds, a Pin/like/save flow, board creation, search, saved boards, the native photo picker, profile editing, dark appearance, and successful native Clerk sign-in. The Create Pin media/persistence path is additionally covered by an automated widget test with a selected-photo fixture. The OS picker was opened on iOS; its photo-selection gesture was not automated.

## Optional narrated walkthrough guide

Record the **actual app** in an iOS simulator or device, with touch/cursor interactions. Use a microphone if you want narration. Keep credentials, personal email, and provider dashboards out of the recording.

| Time | Demonstration | Explain |
| --- | --- | --- |
| 0:00–0:45 | Browse the For you masonry feed; scroll and switch topic chips. | Flutter mobile app, live Unsplash photos, lazy layout, reserved aspect ratios, image caching. |
| 0:45–1:30 | Open a Pin, like it, open Save, create a board, save the Pin. Scroll related ideas and go back. | Hero transition, haptics, persistent likes, board selection, photographer/source attribution. |
| 1:30–2:15 | Open Search, explore Interiors or Travel, submit a query, clear it to show recent searches, return to Home. | Debounce, API results, loading and empty states, independent tab scroll positions. |
| 2:15–3:00 | Open Saved, inspect the board, edit its name/description, browse saved Pins, remove one if desired. | Serialized durable local writes and device-local storage, per-account separation. |
| 3:00–3:45 | Create a Pin from the photo library, enter a title and description, choose a board, and open Created. | Native picker, validation, resized media, persisted image bytes rather than temporary paths. |
| 3:45–4:30 | Open Profile, edit it, visit Settings, switch dark appearance, inspect Updates, switch tabs. | Real activity history, reactive Riverpod state, accessibility labels and retained navigation. |
| 4:30–5:15 | Show Clerk's actual login/signup UI or a signed-in test profile, log out if appropriate, finish on the feed. | Clerk handles credentials/session; public photo keys stay out of Git; explain Clean Architecture and 13 passing tests. |

## Record with the SDK

```sh
flutter run -d <simulator-id> --dart-define-from-file=config/local.json
# In a second terminal:
xcrun simctl io <simulator-id> recordVideo --codec=h264 artifacts/ios-walkthrough.mp4
# Use the app for 5–10 minutes. Ctrl-C ends recording and finalizes the file.
```

The installed Xcode version presents simulators in **Device Hub**. Its Record control is an alternative. A screenshot can be captured with `xcrun simctl io <simulator-id> screenshot artifacts/ios-feed.png`. Review the entire recording before submitting it.
