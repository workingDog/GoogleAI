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
    
    @State private var selectedConverseId = UUID()
    @State private var selecteImagedId = UUID()
    
    @ViewBuilder
    func txtView(_ converse: Conversation) -> some View {
        Text(converse.question.text)
            .font(.system(size: CGFloat(interface.textSize)))
            .padding(.all, 10)
            .foregroundStyle(txtIsPressed && (selectedConverseId == converse.id) ? interface.copyColor : interface.textColor)
            .onTapGesture {
                UIPasteboard.general.string = converse.question.text
                aiManager.shareItem = converse.question.text
                selectedConverseId = converse.id
                txtIsPressed.toggle()
            }
    }
    
    @ViewBuilder
    func imgView(_ converse: Conversation) -> some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(converse.question.images) { image in
                    Image(uiImage: image.uimage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 333, maxHeight: 333)
                        .border(imgIsPressed && (selecteImagedId == image.id) ? interface.copyColor : interface.textColor, width: 4)
                        .padding(8)
                        .onTapGesture {
                            UIPasteboard.general.image = image.uimage
                            aiManager.shareItem = image.uimage
                            selectedConverseId = converse.id
                            selecteImagedId = image.id
                            imgIsPressed.toggle()
                        }
                }
            }
        }
    }
    
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(aiManager.conversations) { converse in
                    VStack {
                        ChatBubble(direction: .left) {
                            //   LeftBubble {
                            VStack(alignment: .leading) {
                                txtView(converse)
                                imgView(converse)
                            }
                            .background(txtIsPressed && (selectedConverseId == converse.id) ? interface.copyColor : interface.questionColor)
                            
                            .onTapGesture {
                                UIPasteboard.general.string = converse.question.text
                                selectedConverseId = converse.id
                                aiManager.shareItem = converse.question.text
                                txtIsPressed.toggle()
                            }
                        }
                        .animation(.easeInOut(duration: 0.1)
                            .reverse(on: $imgIsPressed, delay: 0.1), value: imgIsPressed)
                        .animation(.easeInOut(duration: 0.1)
                            .reverse(on: $txtIsPressed, delay: 0.1), value: txtIsPressed)
                        
                        RightBubbleView(converse: converse, isThinking: $isThinking)
                    }
                    .id(converse.id)
                    .listRowBackground(interface.backColor)
                    .simultaneousGesture(TapGesture()
                        .onEnded {
                            selectedConverseId = converse.id
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
