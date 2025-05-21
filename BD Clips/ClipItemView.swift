//
//  VideoPlayerView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI

struct ClipItemView: View {
    var video: VideoModel
    @State private var isPlaying: Bool = true
    @Binding var selectedVideoIndex : Int
    
    var body: some View {
        ZStack {
            // Video Player (in a real app, you'd implement an actual video player)
            Color.black.opacity(0.8) // Placeholder for video
                .overlay(
                     
                    RealVideoPlayerView(videoURL: video.videoURL, selectedVideoIndex: $selectedVideoIndex)
                )
            
            // UI Overlay
            VStack {
                Spacer()
                
                // Caption and username area
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.username)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(video.caption)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Right side buttons
                    VStack(spacing: 20) {
                        Button(action: {
                            //video.isLiked.toggle()
                        }) {
                            VStack {
                                Image(systemName: video.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(video.isLiked ? .red : .white)
                                    .font(.system(size: 30))
                                
                                Text("\(video.likes + (video.isLiked ? 1 : 0))")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "message")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                
                                Text("124")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                
                                Text("Share")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        
                        // Profile picture
                        Button(action: {}) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
            }
        }
        .onTapGesture {
            isPlaying.toggle()
        }
    }
}

#Preview {
    ClipItemView(video: VideoModel.videos.first!, selectedVideoIndex: .constant(0)  )
}
