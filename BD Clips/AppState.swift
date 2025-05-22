//
//  AppState.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/22/25.
//

import Foundation

class AppState: ObservableObject {
    @Published var currentIndex: Int = 0
    private var scrollDebounceTimer: Timer?
    private let scrollDebounceDelay: TimeInterval = 0.3 // Wait 300ms after scroll stops
    
    init() {
        // Auto-play first video when app starts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.playCurrentVideo()
        }
    }
    
    func updateCurrentIndex(_ newIndex: Int) {
        guard newIndex != currentIndex else { return }
        currentIndex = newIndex
        
        // Cancel previous timer
        scrollDebounceTimer?.invalidate()
        
        // Debounce rapid scrolling - only play video after scroll stops
        scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: scrollDebounceDelay, repeats: false) { _ in
            DispatchQueue.main.async {
                self.playCurrentVideo()
            }
        }
        
        // For immediate visual feedback, pause current video but don't start new one yet
        VideoPlayerManager.shared.pauseCurrentVideo()
    }
    
    func playCurrentVideo() {
        guard currentIndex >= 0 && currentIndex < VideoModel.videos.count else { return }
        let video = VideoModel.videos[currentIndex]
        VideoPlayerManager.shared.playVideo(at: currentIndex, with: video.videoURL)
    }
    
    // Call this when scrolling stops to immediately play
    func forcePlayCurrent() {
        scrollDebounceTimer?.invalidate()
        playCurrentVideo()
    }
}
