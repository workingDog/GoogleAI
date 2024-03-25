//
//  CompletionView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/28.
//

import Foundation
import SwiftUI


struct CompletionView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @Binding var isThinking: Bool
    
    @State private var txtIsPressed = false
    @State private var imgIsPressed = false
    @State private var tappedImageId: UUID?
    
    @ViewBuilder func txtView(_ converse: Conversation) -> some View {
        Text(converse.question.text)
            .padding(.all, 10)
            .foregroundColor(txtIsPressed && (aiManager.selectedConversation?.id == converse.id) ? interface.copyColor : interface.textColor)
            .onTapGesture {
                UIPasteboard.general.string = converse.question.text
                txtIsPressed.toggle()
            }
    }
    
    @ViewBuilder func imgView(_ converse: Conversation, geo: GeometryProxy) -> some View {
        if let image = converse.question.uimage.first {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: geo.size.width/0.95, maxHeight: 380)
                .border(imgIsPressed ? interface.copyColor : interface.textColor, width: 4)
                .padding(8)
                .onTapGesture {
                    UIPasteboard.general.image = image
                    imgIsPressed.toggle()
                }
        }
    }
    
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                List {
                    ForEach(aiManager.conversations) { converse in
                        VStack {
                            ChatBubble(direction: .left) {
                                //   LeftBubble {
                                VStack {
                                    txtView(converse)
                                    imgView(converse, geo: geo)
                                }
                                .background(txtIsPressed && (aiManager.selectedConversation?.id == converse.id) ? interface.copyColor : interface.questionColor)
                                
                                .onTapGesture {
                                    UIPasteboard.general.string = converse.question.text
                                    aiManager.selectedConversation = converse
                                    txtIsPressed.toggle()
                                }
                            }
                            .animation(.easeInOut(duration: 0.2)
                                .reverse(on: $imgIsPressed, delay: 0.2), value: imgIsPressed)
                            .animation(.easeInOut(duration: 0.2)
                                .reverse(on: $txtIsPressed, delay: 0.2), value: txtIsPressed)
                            
                            RightBubbleView(converse: converse, isThinking: $isThinking)
                        }
                        .id(converse.id)
                        .listRowBackground(interface.backColor)
                        .simultaneousGesture(TapGesture()
                            .onEnded {
                                aiManager.selectedConversation = converse
                            })
                    }
                    .onDelete { index in
                        if let firstNdx = index.first {
                            aiManager.conversations.remove(at: firstNdx)
                        }
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                .onChange(of: aiManager.haveResponse) {
                    if let last = aiManager.conversations.last {
                        proxy.scrollTo(last.id)
                    }
                }
            }
        }
    }
    
}
