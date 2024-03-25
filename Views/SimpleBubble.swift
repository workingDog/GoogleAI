//
//  SimpleBubble.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/06/06.
//

import Foundation
import SwiftUI



struct LeftBubble<Content>: View where Content: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            content().clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            Spacer()
        }
        .padding([.leading, .top, .bottom], 10)
        .padding(.trailing, 10)
    }
}

struct RightBubble<Content>: View where Content: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            Spacer()
            content().clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
        }
        .padding([.trailing, .top, .bottom], 10)
        .padding(.leading, 10)
    }
}
