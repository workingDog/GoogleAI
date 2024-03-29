//
//  Conversation.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/30.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI



struct ImageItem: Identifiable, Hashable {
    let id = UUID()
    var uimage: UIImage
}

struct InfoItem: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var images: [ImageItem]
}

@Observable class Conversation: Identifiable {
    let id = UUID()
    var question: InfoItem
    var answer: InfoItem
    var history: [ModelContent]
    
    init(question: InfoItem = InfoItem(text: "", images: []),
         answer: InfoItem = InfoItem(text: "", images: []),
         history: [ModelContent] = []) {
        
        self.question = question
        self.answer = answer
        self.history = history
    }
}

 enum RoleType: String, Codable {
    case system
    case user
    case model
}
