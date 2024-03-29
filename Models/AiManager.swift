//
//  OpenAiModel.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
// 

import Foundation
import SwiftUI
import GoogleGenerativeAI

/*
 
 using Google Swift GoogleGenerativeAI library, how to check for usage limit using SwiftUI
 
 
 */

@Observable class AiManager {
    
    var conversations = [Conversation]()
    var selectedConversation: Conversation?
    
    var errorDetected = false
    var haveResponse = false

    var selectedMode: ModeType = .chat
    var modelName = "gemini-1.0-pro-latest"   //"gemini-1.0-pro"
    var config = GenerationConfig(maxOutputTokens: 1000)
    
    @ObservationIgnored var client = GenerativeModel(name: "gemini-1.0-pro-latest", apiKey: "", generationConfig: GenerationConfig(maxOutputTokens: 1000))
    
    init() {
        let apikey = StoreService.getKey() ?? ""
        self.config = StoreService.getModelConfig()
        client = GenerativeModel(name: modelName, apiKey: apikey, generationConfig: config)
    }
    
    func updateModel() {
        let apikey = StoreService.getKey() ?? ""
        switch selectedMode {
            case .chat:
                client = GenerativeModel(name: modelName, apiKey: apikey, generationConfig: config)
            case .image, .camera:
                client = GenerativeModel(name: "gemini-1.0-pro-vision-latest", apiKey: apikey, generationConfig: config)
        }
    }
    
    func updateClientKey(_ apikey: String) {
        client = GenerativeModel(name: modelName, apiKey: apikey, generationConfig: config)
    }
    
    func getResponse(from text: String, images: [UIImage] = []) async {

        conversations.append(Conversation(question: Question(text: text, uimage: images),
                                          answers: [],
                                          history: conversations.last?.history ?? []))
        
        errorDetected = false

        switch selectedMode {
            case .chat: await getChats(from: text)
            case .image, .camera: await getVision(from: text, images: images)
        }
        
        DispatchQueue.main.async {
            self.haveResponse.toggle()
        }
    }

    func getVision(from text: String, images: [UIImage]) async {
        let imagesParts: [any ThrowingPartsRepresentable] = images
        do {
            let results = try await client.generateContent(text, imagesParts)
            if let output = results.text {
                conversations.last?.answers.append(Answer(text: output, uimage: images))
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
                conversations.last?.answers.append(Answer(text: output, uimage: []))
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
