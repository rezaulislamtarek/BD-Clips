//
//  VideoModel.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import Foundation

struct VideoModel: Identifiable {
    let id = UUID()
    let videoURL: URL
    let username: String
    let caption: String
    let likes: Int
    var isLiked: Bool = false
}


extension VideoModel{
    static var videos: [VideoModel] = [
        VideoModel(
            videoURL: URL(string: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/223/media/ZLfFOqwobyNHwuuf_1747292695.mp4")!,
            username: "@user1",
            caption: "ডেঙ্গু প্রতিরোধে করনীয়",
            likes: 1245
        ),
        VideoModel(
            videoURL: URL(string: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/222/media/YXSxBL36tBTQvC7O_1747291905.mp4")!,
            username: "@user2",
            caption: "এই গরমে কী খাবেন, কী খাবেন না",
            likes: 876
        ),
        VideoModel(
            videoURL: URL(string: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/221/media/SMcTSyXRAuHTEpUY_1747291826.mp4")!,
            username: "@user3",
            caption: "হিট স্ট্রোক কী",
            likes: 2453
        ),
        
        VideoModel(
            videoURL: URL(string: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/208/media/zPRydfbFNSwfNWo4_1747050840.mp4")!,
            username: "@user3",
            caption: "একটি ছোট প্রশংসা বদলে দিতে পারে কারও দিন!",
            likes: 2453
        ),
        VideoModel(
            videoURL: URL(string: "https://doctime-clips-dev.s3.ap-southeast-1.amazonaws.com/clips/174/media/jeFduKgWn4Vpv8ku_1746704514.mp4")!,
            username: "@user3",
            caption: "Daily wellness made easy with expert tips and insights.",
            likes: 2453
        ),
        // Add more sample videos as needed
    ]
}
