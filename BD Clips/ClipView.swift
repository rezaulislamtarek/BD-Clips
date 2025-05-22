//
//  ContentView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI

struct ClipView: View {
    @EnvironmentObject private var state: AppState
    @StateObject private var playerManager = VideoPlayerManager.shared
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            TabView(selection: Binding(
                get: { state.currentIndex },
                set: { newValue in
                    state.updateCurrentIndex(newValue)
                }
            )) {
                ForEach(0..<VideoModel.videos.count, id: \.self) { index in
                    let video = VideoModel.videos[index]
                    
                    ClipItemView(
                        video: video,
                        videoIndex: index,
                        isCurrentVideo: state.currentIndex == index
                    )
                    .tag(index)
                    .frame(width: size.width)
                    .overlay(alignment: .topTrailing) {
                        overlayContent(for: index)
                    }
                    .rotationEffect(.degrees(-90))
                }
            }
            .rotationEffect(.init(degrees: 90))
            .frame(width: size.height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: size.width)
            .gesture(
                // Detect when scrolling ends to immediately play video
                DragGesture()
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            state.forcePlayCurrent()
                        }
                    }
            )
        }
        .onAppear {
            // Play first video when view appears
            if !VideoModel.videos.isEmpty {
                print("📱 ClipView appeared, starting first video")
                // Ensure we start with index 0 and play immediately
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if state.currentIndex == 0 {
                        // Force play the first video
                        let firstVideo = VideoModel.videos[0]
                        VideoPlayerManager.shared.playVideo(at: 0, with: firstVideo.videoURL)
                    } else {
                        state.updateCurrentIndex(0)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Resume playing when app becomes active
            if state.currentIndex < VideoModel.videos.count {
                let currentVideo = VideoModel.videos[state.currentIndex]
                VideoPlayerManager.shared.playVideo(at: state.currentIndex, with: currentVideo.videoURL)
            }
        }
        .onDisappear {
            // Stop all videos when view disappears
            VideoPlayerManager.shared.stopAllVideos()
        }
    }
    
    @ViewBuilder
    private func overlayContent(for index: Int) -> some View {
        VStack(spacing: 8) {
            Text("Video \(index + 1)/\(VideoModel.videos.count)")
                .foregroundStyle(.white)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
            
            // Loading indicator
            if playerManager.isLoading && state.currentIndex == index {
                VStack(spacing: 4) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    
                    Text("Loading \(Int(playerManager.loadingProgress * 100))%")
                        .foregroundColor(.white)
                        .font(.caption2)
                }
                .padding(8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(6)
            }
        }
        .padding(.top, 50)
        .padding(.trailing, 16)
    }
}



#Preview {
    ClipView()
        .environmentObject(AppState())
    
}
