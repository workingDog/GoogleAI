//
//  KwuikAIApp.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/04/10.
//

import SwiftUI
import GeminiKit
import SwiftData


@main
struct KwuikAIApp: App {
    @State private var aiManager = AiManager()
    @State private var interface = InterfaceManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SkillModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
                        aiManager.model = GeminiModel(rawName)
                    }
                    // get config from UserDefaults if any
                    if let config = StoreService.getModelConfig() {
                        aiManager.config = config
                    }
                }
                .modelContainer(sharedModelContainer)
        }
    }
}
