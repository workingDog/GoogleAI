//
//  ColorView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/29.
//

import Foundation
import SwiftUI



struct ColorView: View {
    @Environment(InterfaceManager.self) var interface
    
    var body: some View {
        @Bindable var interface = interface
        VStack (spacing: 0) {
            HStack {
                Spacer()
                Button {
                    if interface.textSize < 13 {
                        interface.textSize = 12 // minimum size
                    } else {
                        interface.textSize -= 1
                    }
                } label: {
                    Image(systemName: "textformat.size.smaller")
                }
                Text("\(interface.textSize)").monospacedDigit()
                Button {
                    if interface.textSize > 31 {
                        interface.textSize = 32 // maximum size
                    } else {
                        interface.textSize += 1
                    }
                } label: {
                    Image(systemName: "textformat.size.larger")
                }
                Spacer()
            }.buttonStyle(.borderedProminent)
            
            HStack {
                ColorPicker("Colors", selection: Binding<Color>(
                    get: {
                        switch interface.selectedColor {
                        case .back: return interface.backColor
                        case .text: return interface.textColor
                        case .question: return interface.questionColor
                        case .answer: return interface.answerColor
                        case .copy: return interface.copyColor
                        case .tools: return interface.toolsColor
                        }
                    },
                    set: {
                        switch interface.selectedColor {
                        case .back: interface.backColor = $0
                        case .text: interface.textColor = $0
                        case .question: interface.questionColor = $0
                        case .answer: interface.answerColor = $0
                        case .copy: interface.copyColor = $0
                        case .tools: interface.toolsColor = $0
                        }
                    }
                ))
                .frame(width: 111, height: 40)
                .padding(.bottom, 10)
                Spacer()
                Toggle(isOn: $interface.isDarkMode) {
                    Text("Dark")
                }
                .frame(width: 110)
                .padding(.bottom, 10)
            }
            Picker("", selection: $interface.selectedColor) {
                Text("Back").tag(ColorType.back)
                Text("Text").tag(ColorType.text)
                Text("Question").tag(ColorType.question)
            }
            .pickerStyle(.segmented)
            Picker("", selection: $interface.selectedColor) {
                Text("Answer").tag(ColorType.answer)
                Text("Copy").tag(ColorType.copy)
                Text("Tools").tag(ColorType.tools)
            }
            .pickerStyle(.segmented)
        }
    }
}

