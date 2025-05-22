//
//  VideoPlayerManager.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/22/25.
//

import Foundation
import AVFoundation
import Combine


class VideoPlayerManager: ObservableObject {
    static let shared = VideoPlayerManager()
    
    @Published private(set) var currentPlayer: AVPlayer?
    @Published private(set) var currentVideoIndex: Int?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var loadingProgress: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    private var playbackQueue = DispatchQueue(label: "video.playback.queue", qos: .userInitiated)
    private var lastPlayRequest: Int = -1
    
    private init() {}
    
    func playVideo(at index: Int, with url: URL) {
        // Prevent duplicate requests for same video
        guard index != lastPlayRequest else {
            print("🚫 Skipping duplicate play request for index: \(index)")
            return
        }
        
        lastPlayRequest = index
        
        playbackQueue.async { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                print("🎬 Playing video at index: \(index)")
                
                // Stop current player immediately if playing different video
                if self.currentVideoIndex != index {
                    self.currentPlayer?.pause()
                    self.cancellables.removeAll()
                    self.isLoading = true
                }
                
                // Get cached or create new player
                let player = VideoCacheManager.shared.getCachedPlayer(for: index, url: url)
                self.currentPlayer = player
                self.currentVideoIndex = index
                
                // Setup observers
                self.setupPlayerObservers(for: player)
                
                // Quick start - don't wait for full readiness for cached videos
                if VideoCacheManager.shared.isVideoCached(index: index) {
                    player.seek(to: .zero) { _ in
                        player.play()
                        print("▶️ Cached video started immediately")
                    }
                } else {
                    // For non-cached videos, wait for readiness
                    if let currentItem = player.currentItem {
                        if currentItem.status == .readyToPlay {
                            player.seek(to: .zero) { _ in
                                player.play()
                                print("▶️ Video started playing immediately")
                            }
                        } else {
                            currentItem.publisher(for: \.status)
                                .filter { $0 == .readyToPlay }
                                .first()
                                .receive(on: DispatchQueue.main)
                                .sink { _ in
                                    player.seek(to: .zero) { _ in
                                        player.play()
                                        print("▶️ Video started playing after ready")
                                    }
                                }
                                .store(in: &self.cancellables)
                        }
                    }
                }
                
                // Preload next videos with higher priority
                VideoCacheManager.shared.preloadNextVideos(
                    currentIndex: index,
                    totalVideos: VideoModel.videos.count
                )
            }
        }
    }
    
    func pauseCurrentVideo() {
        DispatchQueue.main.async { [weak self] in
            self?.currentPlayer?.pause()
        }
    }
    
    func resumeCurrentVideo() {
        DispatchQueue.main.async { [weak self] in
            self?.currentPlayer?.play()
        }
    }
    
    func stopAllVideos() {
        playbackQueue.async { [weak self] in
            DispatchQueue.main.async {
                self?.currentPlayer?.pause()
                self?.currentPlayer = nil
                self?.currentVideoIndex = nil
                self?.lastPlayRequest = -1
                self?.cancellables.removeAll()
                VideoCacheManager.shared.clearAllCache()
            }
        }
    }
    
    private func setupPlayerObservers(for player: AVPlayer) {
        guard let playerItem = player.currentItem else { return }
        
        // Simplified loading observer for better performance
        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .waitingToPlayAtSpecifiedRate:
                    self?.isLoading = true
                case .playing:
                    self?.isLoading = false
                    self?.loadingProgress = 1.0
                case .paused:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Setup looping
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak player] _ in
                player?.seek(to: .zero) { _ in
                    player?.play()
                }
            }
            .store(in: &cancellables)
    }
}
