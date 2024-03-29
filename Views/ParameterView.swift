//
//  ParameterView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/29.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI


// just to make things easier in ParameterView sliders etc...
struct PlainConfig: Codable, Equatable {
    var temperature: Float = 0.3
    var topP: Float = 0.95
    var topK: Float = 1
    var candidateCount: Float = 1
    var maxOutputTokens: Float = 1024.0
    var stopSequences: [String] = []
    
    init() { }
    
    init(conf: GenerationConfig) {
        self.temperature = conf.temperature ?? 0.3
        self.topP = conf.topP ?? 0.95
        self.topK = Float(conf.topK ?? 1)
        self.candidateCount = Float(conf.candidateCount ?? 1)
        self.maxOutputTokens = Float(conf.maxOutputTokens ?? 1024)
        self.stopSequences = conf.stopSequences ?? []
    }
}

struct ParameterView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @State private var lang = "en" 
    
    @State private var config = PlainConfig()
    
    var body: some View {
        @Bindable var aiManager = aiManager
        @Bindable var interface = interface
        VStack {

            HStack {
                HStack {
                    Text("Temperature")
                    Text(" \(config.temperature, specifier: "%.1f")     ").foregroundColor(.blue)
                }
                Spacer()
                Slider(value: $config.temperature, in: 0...1, step: 0.1)
            }
            
            HStack {
                HStack {
                    Text("Max tokens")
                    Text(" \(Int(config.maxOutputTokens))   ").foregroundColor(.blue)
                }
                Spacer()
                Slider(value: $config.maxOutputTokens, in: 100...2000, step: 100)
            }
            
            HStack {
                HStack {
                    Text("topP")
                    Text(" \(config.topP, specifier: "%.1f") ").foregroundColor(.blue)
                }
                Spacer()
                Slider(value: $config.topP, in: 0...1, step: 0.1)
            }
            
            HStack {
                HStack {
                    Text("topK")
                    Text(" \(Int(config.topK))   ").foregroundColor(.blue)
                }
                Spacer()
                Slider(value: $config.topK, in: 1...10, step: 1)
            }

            HStack {
                Picker("", selection: $interface.kwuiklang) {
                    Text(verbatim: "English").tag("en")
                    Text(verbatim: "日本語").tag("ja")
                }.pickerStyle(.segmented).frame(width: 222)
            }.padding(10)
            
        }
        .onAppear {
            config = PlainConfig(conf: aiManager.config)
        }
        .onDisappear {
            aiManager.config = GenerationConfig(
                temperature: config.temperature,
                topP: config.topP,
                topK: Int(config.topK),
                candidateCount: Int(config.candidateCount),
                maxOutputTokens: Int(config.maxOutputTokens),
                stopSequences: config.stopSequences)
            aiManager.updateModel()
            StoreService.setModelConfig(config)
        }
    }
}
