//
//  OpenAiModel.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
// 

import Foundation
import SwiftUI
import GeminiKit


@Observable class AiManager {
    
    var conversations = [Conversation]()
    
    var errorDetected = false
    var haveResponse = false

    var shareItem: Any = "nothing to share"

    var selectedMode: ModeType = .chat
    
    @ObservationIgnored var client = GeminiKit(apiKey: "your-api-key")

    // need to call updateModel() after changing `config` or `modelName`
    var config: GenerationConfig

    var model: GeminiModel = .gemini25Flash
    
    init() {
        self.config = GenerationConfig(maxOutputTokens: 1000)
        let apikey = StoreService.getKey() ?? ""
        client = GeminiKit(apiKey: apikey)
    }

    func updateClientKey(_ apikey: String) {
        client = GeminiKit(apiKey: apikey)
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
        // let imagesParts = images.map{$0.uimage}
        
        // ----> need an image model here <----
        
        do {
            var parts: [Part] = []

            // TEXT
            parts.append(.text(text))

            // IMAGES
            for image in images {
                if let data = image.uimage.jpegData(compressionQuality: 0.8) {
                    parts.append(
                        Part.inlineData(InlineData(mimeType: "image/jpeg", data: data))
                    )
                }
            }

            let content = Content(role: .user, parts: parts)
            let request = GenerateContentRequest(contents: [content])
            
            let results = try await client.generateContent(model: model, request: request)

            if let part = results.candidates?.first?.content.parts.first {
                if case let .text(text) = part {
                    conversations.last?.answer = InfoItem(text: text, images: images)
                } else {
                    errorDetected = true
                }
            }
 
        } catch {
            errorDetected = true
            print(error)
        }
    }

    func getChats(from text: String) async {
        var reply: String
        do {
            let history: [Content] = conversations.last?.history ?? []
            let chat = client.startChat(model: model, history: history)
            reply = try await chat.sendMessage(text)
            conversations.last?.answer = InfoItem(text: reply, images: [])
            conversations.last?.history.append(Content(role: .user, parts: [.text(text)]))
            conversations.last?.history.append(Content(role: .model, parts: [.text(reply)]))
        } catch {
            errorDetected = true
            print(error)
        }
    }
    
//    func getAudio(from text: String) async {
//        var results: GenerateContentResponse
//        do {
//            let audioData: Data = Data() //.data(mimetype: "mp3", fileData)
//            results = try await client.generateContent([audioData, text])
//            if let output = results.text {
//                conversations.last?.answer = InfoItem(text: output, images: [])
//                conversations.last?.history.append(ModelContent(role: "user", parts: text))
//                conversations.last?.history.append(ModelContent(role: "model", parts: output))
//            } else {
//                errorDetected = true
//            }
//        } catch {
//            errorDetected = true
//            print(error)
//        }
//    }

}

public enum APIError: Swift.Error, LocalizedError {
    
    case unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)
    
    public var errorDescription: String? {
        switch self {
            case .unknown: return "Unknown error"
            case .apiError(let reason), .parserError(let reason): return reason
            case .networkError(let from): return from.localizedDescription
        }
    }
}
