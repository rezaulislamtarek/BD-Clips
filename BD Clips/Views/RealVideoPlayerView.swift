//
//  RealVideoPlayerView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI
import AVKit
 

struct RealVideoPlayerView: View {
     
    let videoURL: URL
    @State private var player = AVPlayer()
    @State private var isPlaying: Bool = true
    @State private var playerWorkItem: DispatchWorkItem?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                let playerItem = AVPlayerItem(url: videoURL)
                player.replaceCurrentItem(with: playerItem)
                //player.play()
                
                // Loop video
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                      object: player.currentItem,
                                                      queue: .main) { _ in
                    player.seek(to: CMTime.zero)
                    //player.play()
                }
            }
            .onDisappear {
                player.pause()
                NotificationCenter.default.removeObserver(self)
                // Cancel any pending work items
                playerWorkItem?.cancel()
            }
             
    }
}
