//
//  OpenAiModel.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
// 

import Foundation
import SwiftUI
import GoogleGenerativeAI


@Observable class AiManager {
    
    var conversations = [Conversation]()
    
    var errorDetected = false
    var haveResponse = false

    var shareItem: Any = "nothing to share"

    var selectedMode: ModeType = .chat
    
    @ObservationIgnored var client = GenerativeModel(name: "", apiKey: "", generationConfig: GenerationConfig(maxOutputTokens: 1000))

    // need to call updateModel() after changing `config` or `modelName`
    var config: GenerationConfig
    var modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
        self.config = GenerationConfig(maxOutputTokens: 1000)
        let apikey = StoreService.getKey() ?? ""
        client = GenerativeModel(name: self.modelName, apiKey: apikey, generationConfig: config)
    }

    func updateModel() {
        let apikey = StoreService.getKey() ?? ""
        client = GenerativeModel(name: modelName, apiKey: apikey, generationConfig: config)
    }

    func updateClientKey(_ apikey: String) {
        client = GenerativeModel(name: modelName, apiKey: apikey, generationConfig: config)
    }
    
    func getResponse(from text: String, images: [ImageItem] = []) async {

        conversations.append(Conversation(question: InfoItem(text: text, images: images),
                                          answer: InfoItem(text: "", images: []),
                                          history: conversations.last?.history ?? []))
        
        errorDetected = false

        switch selectedMode {
            case .chat: 
                await getChats(from: text)
            case .image, .camera: 
                await getVision(from: text, images: images)
        }
        
        haveResponse.toggle()
    }

    func getVision(from text: String, images: [ImageItem]) async {
        let imagesParts: [any ThrowingPartsRepresentable] = images.map{$0.uimage}
        do {
            let results = try await client.generateContent(text, imagesParts)
            if let output = results.text {
                conversations.last?.answer = InfoItem(text: output, images: images)
            } else {
                errorDetected = true
            }
        } catch {
            errorDetected = true
            print(error)
        }
    }

    func getChats(from text: String) async {
        var results: GenerateContentResponse
        do {
            let history = conversations.last?.history ?? []
            if history.count > 1 {
                let chat = client.startChat(history: history)
                results = try await chat.sendMessage(text)
            } else {
                results = try await client.generateContent(text)
            }
            if let output = results.text {
                conversations.last?.answer = InfoItem(text: output, images: [])
                conversations.last?.history.append(ModelContent(role: "user", parts: text))
                conversations.last?.history.append(ModelContent(role: "model", parts: output))
            } else {
                errorDetected = true
            }
        } catch {
            errorDetected = true
            print(error)
        }
    }

}
