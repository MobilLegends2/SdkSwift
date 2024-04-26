import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack {
            Text("Camera")
                .font(.title)
                .padding()
            
            CameraPreview(session: viewModel.session)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            Button(action: {
                viewModel.capturePhoto()
            }) {
                Text("Capture Photo")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showSettingAlert) {
            Alert(
                title: Text("Camera Permission"),
                message: Text("Please allow camera access in Settings."),
                primaryButton: .default(Text("Settings"), action: {
                    viewModel.openSettings()
                }),
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            viewModel.checkCameraPermission()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.layer.bounds
        view.layer.addSublayer(layer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else {
            return
        }
        layer.frame = uiView.layer.bounds
    }
}

class CameraPhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        completion(image)
    }
}

class CameraViewModel: ObservableObject {
    @Published var session: AVCaptureSession = AVCaptureSession()
    @Published var showSettingAlert = false
    
    private let photoOutput = AVCapturePhotoOutput()
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUpCamera()
        case .notDetermined:
            requestCameraPermission()
        default:
            showSettingAlert = true
        }
    }
    
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: CameraPhotoCaptureDelegate { [weak self] image in
            guard image != nil else { return }
            
            // Process captured image
            // ...
        })
    }
    
    private func setUpCamera() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera)
        else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setUpCamera()
                } else {
                    self?.showSettingAlert = true
                }
            }
        }
    }
}
