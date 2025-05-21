//
//  ContentView.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI

 
struct ContentView: View {
    
    @State private var selectedVideoIndex = 0
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
           
            // Vertical pagetab view
            TabView(selection: $selectedVideoIndex) {
                ForEach(VideoModel.videos){ video in
                    ClipItemView(video: video, selectedVideoIndex: $selectedVideoIndex)
                        .frame(width: size.width)
                        .rotationEffect(.degrees(-90))
                }
            }
            .rotationEffect(.init(degrees: 90))
            .frame(width: size.height)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: size.width)
            .onChange(of: selectedVideoIndex) { newValue in
                print("Selected Video Index : \(newValue)")
            }
            .onAppear{
                print("Selected Video Index : \(selectedVideoIndex)")
            }
            
        }
    }
}


#Preview {
    ContentView()
         
}
