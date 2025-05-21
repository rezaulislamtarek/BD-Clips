//
//  ContentView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI

class AppState : ObservableObject {
    @Published var currentIndex: Int = 0
}

 
struct ClipView: View {
    
    @EnvironmentObject private var state: AppState
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
           
            // Vertical pagetab view
            TabView(selection: $state.currentIndex) {
                ForEach(Array(VideoModel.videos.enumerated()), id: \.element.id){ index, video in
                   
                        ClipItemView(video: video, selectedVideoIndex: .constant(0))
                        .tag(index)
                            .frame(width: size.width)
                            .overlay {
                                Text("Current Index \(state.currentIndex)")
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                            .rotationEffect(.degrees(-90))
                }
            }
            .rotationEffect(.init(degrees: 90))
            .frame(width: size.height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: size.width)
        }
        .onChange(of: state.currentIndex) { newValue in
            print("Selected Video Index : \(newValue)")
            
        }
         
    }
}


#Preview {
    ClipView()
        .environmentObject(AppState())
         
}
