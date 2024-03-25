//
//  Conversation.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/30.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI


struct Answer: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var uimage: [UIImage]
}

struct Question: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var uimage: [UIImage]
}

@Observable class Conversation: Identifiable {
    let id = UUID()
    var question: Question
    var answers: [Answer]
    var history: [ModelContent]
    
    init(question: Question = Question(text: "", uimage: []),
         answers: [Answer] = [],
         history: [ModelContent] = []) {
        
        self.question = question
        self.answers = answers
        self.history = history
    }
}

 enum RoleType: String, Codable {
    case system
    case user
    case model
}
