import AVFoundation
import Combine
import Foundation

enum CameraFrameProviderError: LocalizedError {
    case permissionDenied
    case noCamera
    case cannotAddInput
    case cannotAddOutput

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Camera permission is required for live gesture recognition."
        case .noCamera:
            "No available camera was found on this device."
        case .cannotAddInput:
            "The camera input could not be added to the capture session."
        case .cannotAddOutput:
            "The video output could not be added to the capture session."
        }
    }
}

final class CameraFrameProvider: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @Published private(set) var isRunning = false
    @Published private(set) var errorMessage: String?

    var frameHandler: ((CMSampleBuffer) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.signa.camera.session", qos: .userInitiated)
    private let frameQueue = DispatchQueue(label: "com.signa.camera.frames", qos: .userInitiated)
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isConfigured = false

    func requestAccessAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            start()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }

                self.publishAuthorizationStatus()

                if granted {
                    self.start()
                } else {
                    self.publish(error: CameraFrameProviderError.permissionDenied)
                }
            }
        default:
            publishAuthorizationStatus()
            publish(error: CameraFrameProviderError.permissionDenied)
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.session.isRunning {
                self.session.stopRunning()
            }

            self.publishRunningState(false)

            if let completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }

    private func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            do {
                try self.configureSessionIfNeeded()

                if !self.session.isRunning {
                    self.session.startRunning()
                }

                self.publish(error: nil)
                self.publishRunningState(true)
            } catch {
                self.publishRunningState(false)
                self.publish(error: error)
            }
        }
    }

    private func configureSessionIfNeeded() throws {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        else {
            session.commitConfiguration()
            throw CameraFrameProviderError.noCamera
        }

        let input = try AVCaptureDeviceInput(device: camera)

        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraFrameProviderError.cannotAddInput
        }

        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: frameQueue)

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            throw CameraFrameProviderError.cannotAddOutput
        }

        session.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }

            if connection.isVideoMirroringSupported, camera.position == .front {
                connection.isVideoMirrored = true
            }
        }

        session.commitConfiguration()
        isConfigured = true
    }

    private func publishAuthorizationStatus() {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        }
    }

    private func publishRunningState(_ isRunning: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isRunning = isRunning
        }
    }

    private func publish(error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = error?.localizedDescription
        }
    }
}

extension CameraFrameProvider: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        frameHandler?(sampleBuffer)
    }
}
