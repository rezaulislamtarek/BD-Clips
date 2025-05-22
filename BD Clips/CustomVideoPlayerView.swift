//
//  CustomVideoPlayerView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/22/25.
//

import SwiftUI
import AVKit

struct CustomVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing player layers
        uiView.layer.sublayers?.removeAll { $0 is AVPlayerLayer }
        
        guard let player = player else { return }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = uiView.bounds
        
        uiView.layer.addSublayer(playerLayer)
        
        // Ensure frame updates
        DispatchQueue.main.async {
            playerLayer.frame = uiView.bounds
        }
    }
}
