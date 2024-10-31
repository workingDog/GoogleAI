//
//  RightBubbleView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/30.
//

import Foundation
import SwiftUI
import MarkdownUI


struct RightBubbleView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    let converse: Conversation
    @Binding var isThinking: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        ChatBubble(direction: .right) {
            // RightBubble {
            if isThinking && (converse.id == aiManager.conversations.last?.id) {
                ProgressView()
                    .progressViewStyle(IconRotateStyle())
                    .frame(width: 333, height: 111)
                    .padding(.all, 10)
                    .background(interface.answerColor)
            } else {
                Markdown(converse.answer.text)
                    .markdownTextStyle {
                        FontFamilyVariant(.normal)
                        FontSize(CGFloat(interface.textSize))
                        ForegroundColor(interface.textColor)
                    }
                    .markdownBlockStyle(\.codeBlock) { configuration in
                        configuration.label
                            .relativeLineSpacing(.em(0.25))
                            .markdownTextStyle {
                                FontFamilyVariant(.monospaced)
                                FontSize(CGFloat(interface.textSize))
                                ForegroundColor(interface.textColor)
                            }
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .markdownMargin(top: .zero, bottom: .em(0.8))
                    }
    
                // without markdown and its dependency
                // Text(LocalizedStringKey(converse.answer.text))
                //  .foregroundStyle(interface.textColor)
                    .padding(.all, 15)
                    .background(isPressed ? interface.copyColor : interface.answerColor)
                    .onTapGesture {
                        UIPasteboard.general.string = converse.answer.text
                        aiManager.shareItem = converse.answer.text
                        isPressed.toggle()
                    }
                    .animation(.easeInOut(duration: 0.1)
                        .reverse(on: $isPressed, delay: 0.1), value: isPressed)
                    .frame(alignment: .leading)
            }
        }
    }
}
