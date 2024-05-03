import SwiftUI
import AgoraRtcKit
import AVFoundation

struct VideoCallView: View {
    let currentUser: String
    let conversationId: String
    
    @State private var isMuted = false
    @State private var isCameraEnabled = false // New state for camera permission
    
    var body: some View {
        VStack {
            Text("Video Call View")
                .font(.title)
                .padding()
            
            Spacer()
            
            // Video Call Renderer
            AgoraVideoView(conversationId: conversationId)
                .frame(width: 300, height: 300)
                .cornerRadius(8)
                .padding()
            
            Spacer()
            
            // Hang Up Button
            Button(action: hangUpCall) {
                Text("Hang Up")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            // Mute Button
            Button(action: toggleMute) {
                Text(isMuted ? "Unmute" : "Mute")
                    .padding()
                    .foregroundColor(.white)
                    .background(isMuted ? Color.green : Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .onAppear {
            // Request microphone and camera permissions
            AVAudioSession.sharedInstance().requestRecordPermission { [self] (granted) in
                if granted {
                    AVCaptureDevice.requestAccess(for: .video) { (cameraGranted) in
                        DispatchQueue.main.async {
                            if cameraGranted {
                                // Microphone and camera access granted, initialize Agora RTC Engine
                                let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "d79ab7f5156d4cd1a683fe6e24506a6f", delegate: nil)
                                
                                // Join Channel
                                agoraKit.joinChannel(byToken: nil, channelId: conversationId, info: nil, uid: 0) { (channel, uid, elapsed) in
                                    // Handle join success
                                    print("Successfully joined channel \(channel) with user id \(uid)")
                                }
                                
                                agoraKit.setChannelProfile(.communication)
                                agoraKit.setClientRole(.broadcaster)
                                
                                // Set camera enabled flag to true
                                isCameraEnabled = true
                            } else {
                                // Camera access denied
                                print("Camera access denied")
                            }
                        }
                    }
                } else {
                    // Microphone access denied
                    print("Microphone access denied")
                }
            }
        }
        .onDisappear {
            // Leave Channel
            let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "d79ab7f5156d4cd1a683fe6e24506a6f", delegate: nil)
            agoraKit.leaveChannel(nil)
            AgoraRtcEngineKit.destroy()
        }
    }
    
    func hangUpCall() {
        // Handle hanging up the call
    }
    
    func toggleMute() {
        isMuted.toggle()
        // Handle muting/unmuting the audio
    }
}

struct AgoraVideoView: UIViewRepresentable {
    let conversationId: String
    
    func makeUIView(context: Context) -> UIView {
        // Implement Agora video view setup
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update Agora video view if needed
    }
}
