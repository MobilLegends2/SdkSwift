import SwiftUI
import AgoraRtcKit
import AVFoundation

struct VideoCallView: View {
    let currentUser: String
    let conversationId: String
    
    var body: some View {
        VStack {
            Text("Video Call View")
                .font(.title)
                .padding()
            
            // Add your video call UI components here
            
            Spacer()
        }
        .onAppear {
            // Request microphone permission
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                if granted {
                    // Microphone access granted, initialize Agora RTC Engine
                    let agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "d79ab7f5156d4cd1a683fe6e24506a6f", delegate: nil)
                    
                    // Join Channel
                    agoraKit.joinChannel(byToken: nil, channelId: conversationId, info: nil, uid: 0) { (channel, uid, elapsed) in
                        // Handle join success
                        print("Successfully joined channel \(channel) with user id \(uid)")
                    }
                    
                    agoraKit.setChannelProfile(.communication)
                    agoraKit.setClientRole(.broadcaster)
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
}
