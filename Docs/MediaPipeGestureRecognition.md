# MediaPipe Gesture Recognition Integration

ASLearner uses `GestureRecognitionServiceProtocol` as the boundary between SwiftUI screens and the recognition engine. The default container now points to `MediaPipeGestureRecognitionService`, which falls back to `MockGestureRecognitionService` until MediaPipe and the `.task` model are added.

## Dependency

MediaPipe Gesture Recognizer for iOS is distributed through CocoaPods:

```ruby
target 'ASLearner' do
  use_frameworks!
  pod 'MediaPipeTasksVision'
end
```

After installing pods, open `ASLearner.xcworkspace`.

## Model

Add the model file to the app target:

```text
ASLearner/Resources/Models/gesture_recognizer.task
```

The initial model can be the official canned Gesture Recognizer model. For the app vocabulary, train a custom model with labels matching:

```text
hello
thank_you
yes
no
please
help
good
bad
i_love_you
learn
none
```

`GestureRecognitionResultMapper` maps these labels to `GestureType`.

## Runtime Pipeline

The intended camera pipeline is:

```text
AVCaptureVideoDataOutput
  -> CMSampleBuffer
  -> GestureRecognitionFrame
  -> MediaPipeGestureRecognitionService.recognize(frame:target:)
  -> GestureRecognitionResult
  -> CameraRecognitionView / LearningGesturePracticeView
```

The MediaPipe service currently uses `.video` mode, which processes frames synchronously on a background caller. For a production live preview, the same service can be switched to `.liveStream` and a `GestureRecognizerLiveStreamDelegate`.

## Thresholds

The default thresholds are stored in `GestureRecognitionConfiguration`:

- `recognizedThreshold`: `0.75`
- `lowConfidenceThreshold`: `0.45`
- hand detection/presence/tracking confidence: `0.5...0.55`

These values are intentionally conservative for a learning app. They should be tuned after collecting test recordings.
