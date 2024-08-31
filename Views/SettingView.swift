//
//  SettingView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
//

import Foundation
import SwiftUI


struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @State private var showKey = false

    
    var body: some View {
        ZStack {
            interface.backColor
            ScrollView {
                VStack (alignment: .leading, spacing: 15) {
                #if targetEnvironment(macCatalyst)
                    HStack {
                        Button("Done") {
                            dismiss()
                        }.padding(10)
                        Spacer()
                    }
                #endif
                    Spacer()
                    
                    ParameterView()
                    
                    Divider()
                    ColorView()
                    
                    Spacer()

                    Divider()
                    HStack {
                        Spacer()
                        Button(action: {showKey = true}) {
                            Text("Enter key").padding(15)
                        }
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.pink))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showKey) {
            KeyView()
                .environment(aiManager)
                .environment(interface)
        }
        .preferredColorScheme(interface.isDarkMode ? .dark : .light)
        .environment(\.locale, Locale(identifier: interface.kwuiklang))
        .onDisappear {
            doSave()
        }
    }
    
    func doSave() {
        StoreService.setColor(ColorType.back, color: interface.backColor)
        StoreService.setColor(ColorType.text, color: interface.textColor)
        StoreService.setColor(ColorType.question, color: interface.questionColor)
        StoreService.setColor(ColorType.answer, color: interface.answerColor)
        StoreService.setColor(ColorType.copy, color: interface.copyColor)
        StoreService.setColor(ColorType.tools, color: interface.toolsColor)
        StoreService.setLang(interface.kwuiklang)
        StoreService.setDisplayMode(interface.isDarkMode)
        StoreService.setTextSize(interface.textSize)
        
        dismiss()
    }
    
}

