//
//  VideoPlayerView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI
import AVKit

struct ClipItemView: View {
    let video: VideoModel
    let videoIndex: Int
    let isCurrentVideo: Bool
    
    @StateObject private var playerManager = VideoPlayerManager.shared
    @State private var showControls = false
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background
            Color.black
            
            // Video Player or Placeholder
            if isCurrentVideo && playerManager.currentVideoIndex == videoIndex {
                CustomVideoPlayerView(player: playerManager.currentPlayer)
            } else {
                placeholderView
            }
            
            // Loading overlay
            if playerManager.isLoading && isCurrentVideo {
                loadingOverlay
            }
            
            // Tap gesture
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    handleTap()
                }
                .onLongPressGesture {
                    toggleControls()
                }
            
            // UI Overlay
            uiOverlay
            
            // Controls overlay
            if showControls && isCurrentVideo {
                controlsOverlay
            }
        }
        .onChange(of: isCurrentVideo) { newValue in
            if newValue {
                print("🔄 ClipItemView became current: \(videoIndex)")
                // Don't delay for cached videos
                if VideoCacheManager.shared.isVideoCached(index: videoIndex) {
                    VideoPlayerManager.shared.playVideo(at: videoIndex, with: video.videoURL)
                } else {
                    // Small delay only for non-cached videos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        VideoPlayerManager.shared.playVideo(at: videoIndex, with: video.videoURL)
                    }
                }
            } else {
                print("⏸️ ClipItemView no longer current: \(videoIndex)")
            }
        }
        .clipped()
    }
    
    private var placeholderView: some View {
        Color.black.opacity(0.8)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Video \(videoIndex + 1)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                }
            )
    }
    
    private var loadingOverlay: some View {
        Color.black.opacity(0.4)
            .overlay(
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Buffering...")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    
                    ProgressView(value: playerManager.loadingProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .frame(width: 120)
                }
            )
    }
    
    private var uiOverlay: some View {
        VStack {
            Spacer()
            
            HStack(alignment: .bottom) {
                // Left side info
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.username)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(video.caption)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(.leading)
                
                Spacer()
                
                // Right side buttons
                VStack(spacing: 16) {
                    actionButton(
                        icon: video.isLiked ? "heart.fill" : "heart",
                        color: video.isLiked ? .red : .white,
                        text: "\(video.likes)"
                    )
                    
                    actionButton(icon: "message", color: .white, text: "124")
                    actionButton(icon: "square.and.arrow.up", color: .white, text: "Share")
                    
                    Button(action: {}) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing)
            }
            .padding(.bottom, 20)
        }
    }
    
    private var controlsOverlay: some View {
        Color.black.opacity(0.5)
            .overlay(
                HStack(spacing: 50) {
                    Button(action: {
                        playerManager.pauseCurrentVideo()
                        hideControlsAfterDelay()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        playerManager.resumeCurrentVideo()
                        hideControlsAfterDelay()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
            )
            .onTapGesture {
                hideControls()
            }
    }
    
    private func actionButton(icon: String, color: Color, text: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 24))
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.caption2)
            }
        }
    }
    
    private func handleTap() {
        guard isCurrentVideo else { return }
        
        if let player = playerManager.currentPlayer {
            if player.timeControlStatus == .playing {
                playerManager.pauseCurrentVideo()
            } else {
                playerManager.resumeCurrentVideo()
            }
        }
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls.toggle()
        }
        
        if showControls {
            hideControlsAfterDelay()
        }
    }
    
    private func hideControls() {
        controlsTimer?.invalidate()
        withAnimation(.easeInOut(duration: 0.2)) {
            showControls = false
        }
    }
    
    private func hideControlsAfterDelay() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
            hideControls()
        }
    }
}
