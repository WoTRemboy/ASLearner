# Gesture Recognition Models

Place the MediaPipe Gesture Recognizer model here before adding it to the Xcode target:

```text
gesture_recognizer.task
```

The app looks for this file in `Bundle.main` through `GestureRecognitionConfiguration.mediaPipeDefault`.
Use the official MediaPipe canned model for the first integration pass, then replace it with a custom model trained for the app gesture set.
