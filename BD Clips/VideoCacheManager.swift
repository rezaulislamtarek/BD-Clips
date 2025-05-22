//
//  VideoCacheManager.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/22/25.
//

import SwiftUI
import AVKit
import Combine

class VideoCacheManager: ObservableObject {
    static let shared = VideoCacheManager()
    
    private var cachedPlayers: [Int: AVPlayer] = [:]
    private var cacheQueue = DispatchQueue(label: "video.cache.queue", qos: .userInitiated) // Higher priority
    private let maxCacheSize = 5 // Increased cache size for fast scrolling
    
    private init() {}
    
    func isVideoCached(index: Int) -> Bool {
        return cachedPlayers[index] != nil
    }
    
    func getCachedPlayer(for index: Int, url: URL) -> AVPlayer {
        if let cachedPlayer = cachedPlayers[index] {
            print("📦 Using cached player for index: \(index)")
            return cachedPlayer
        }
        
        print("🆕 Creating new player for index: \(index)")
        let player = AVPlayer(url: url)
        
        // Configure player for better performance
        player.automaticallyWaitsToMinimizeStalling = false
        player.preventsDisplaySleepDuringVideoPlayback = true
        
        cachedPlayers[index] = player
        
        // Aggressive preloading for immediate playback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let playerItem = player.currentItem {
                // Force immediate loading
                playerItem.preferredForwardBufferDuration = 1.0 // Only buffer 1 second ahead
                playerItem.seek(to: CMTime(seconds: 0.01, preferredTimescale: 1000)) { _ in
                    playerItem.seek(to: .zero, completionHandler: nil)
                }
            }
        }
        
        return player
    }
    
    func preloadNextVideos(currentIndex: Int, totalVideos: Int) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let videosToPreload = self.getVideosToPreload(currentIndex: currentIndex, totalVideos: totalVideos)
            
            // Prioritize immediate next video
            let priorityOrder = videosToPreload.sorted { abs($0 - currentIndex) < abs($1 - currentIndex) }
            
            for index in priorityOrder {
                if index < VideoModel.videos.count && index >= 0 && self.cachedPlayers[index] == nil {
                    let video = VideoModel.videos[index]
                    DispatchQueue.main.async {
                        let player = AVPlayer(url: video.videoURL)
                        player.automaticallyWaitsToMinimizeStalling = false
                        self.cachedPlayers[index] = player
                        
                        // Immediate preload for next video
                        if abs(index - currentIndex) <= 1 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let playerItem = player.currentItem {
                                    playerItem.preferredForwardBufferDuration = 1.0
                                    playerItem.seek(to: CMTime(seconds: 0.01, preferredTimescale: 1000)) { _ in
                                        playerItem.seek(to: .zero, completionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            self.cleanupOldCache(currentIndex: currentIndex, totalVideos: totalVideos)
        }
    }
    
    private func getVideosToPreload(currentIndex: Int, totalVideos: Int) -> [Int] {
        var videosToPreload: [Int] = []
        
        // Preload more videos for fast scrolling
        for offset in 1...3 {
            // Next videos
            let nextIndex = (currentIndex + offset) % totalVideos
            if nextIndex != currentIndex {
                videosToPreload.append(nextIndex)
            }
            
            // Previous videos
            let prevIndex = currentIndex - offset < 0 ? totalVideos + (currentIndex - offset) : currentIndex - offset
            if prevIndex != currentIndex && !videosToPreload.contains(prevIndex) {
                videosToPreload.append(prevIndex)
            }
        }
        
        return videosToPreload
    }
    
    private func cleanupOldCache(currentIndex: Int, totalVideos: Int) {
        let videosToKeep = Set(getVideosToPreload(currentIndex: currentIndex, totalVideos: totalVideos) + [currentIndex])
        
        for (index, player) in cachedPlayers {
            if !videosToKeep.contains(index) {
                DispatchQueue.main.async {
                    player.pause()
                    player.replaceCurrentItem(with: nil)
                }
                cachedPlayers.removeValue(forKey: index)
            }
        }
    }
    
    func clearAllCache() {
        DispatchQueue.main.async { [weak self] in
            self?.cachedPlayers.values.forEach { player in
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
            self?.cachedPlayers.removeAll()
        }
    }
}
