//
//  KwuikAIApp.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/04/10.
//

import SwiftUI
import Observation

@main
struct KwuikAIApp: App {
    @State private var aiManager = AiManager(modelName: "gemini-1.5-flash") 
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
                    if let model = StoreService.getModelName() {
                        aiManager.modelName = model
                        aiManager.updateModel()
                    } 
                    // get config from UserDefaults if any
                    if let config = StoreService.getModelConfig() {
                        aiManager.config = config
                        aiManager.updateModel()
                    }
                }
        }
    }
}
