//
//  KwuikAIApp.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/04/10.
//

import SwiftUI
import GeminiKit



@main
struct KwuikAIApp: App {
    @State private var aiManager = AiManager()
    @State private var interface = InterfaceManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(aiManager)
                .environment(interface)
                .environment(\.locale, Locale(identifier: interface.kwuiklang))
                .preferredColorScheme(interface.isDarkMode ? .dark : .light)
                .onAppear {
                    // get model name from UserDefaults if any
                    if let rawName = StoreService.getModelName() {
                        aiManager.model = GeminiModel(rawValue: rawName) ?? .gemini25Flash
                    }
                    // get config from UserDefaults if any
                    if let config = StoreService.getModelConfig() {
                        aiManager.config = config
                    }
                }
        }
    }
}
