//
//  StoreService.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI


class StoreService {
    
    static func getKey() -> String? {
        return KeychainInterface.getPassword()
    }
    
    static func setKey(key: String) {
        do {
            try KeychainInterface.savePassword(key)
        } catch {
            print("in StoreService setKey(), KeychainInterface.savePassword: \(error)")
        }
    }
    
    static func updateKey(key: String) {
        do {
            try KeychainInterface.updatePassword(with: key)
        } catch {
            print("in StoreService updateKey(), KeychainInterface.updatePassword: \(error)")
        }
    }
    
    
    static func setColor(_ key: ColorType, color: Color) {
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
            UserDefaults.standard.set(colorData, forKey: "ringow.com.kwuikai.color.\(key.rawValue)")
        } catch {
            print("in StoreService setColor error: \(error)")
        }
    }
    
    static func getColor(_ key: ColorType) -> Color {
        do {
            if let colorData = UserDefaults.standard.data(forKey: "ringow.com.kwuikai.color.\(key.rawValue)"),
               let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                return Color(uiColor: uiColor)
            }
        } catch {
            print("in StoreService getColor error: \(error)")
        }
        switch key {
            case ColorType.back: return Color.teal
            case ColorType.text: return Color.white
            case ColorType.question: return Color.green
            case ColorType.answer: return Color.blue
            case ColorType.copy: return Color.red
            case ColorType.tools: return Color.blue
        }
    }
    
    static func getLang() -> String {
        return UserDefaults.standard.string(forKey: "ringow.com.kwuikai.defaultlang.key") ?? "en"
    }
    
    static func setLang(_ str: String) {
        UserDefaults.standard.set(str, forKey: "ringow.com.kwuikai.defaultlang.key")
    }
    
    static func getDisplayMode() -> Bool {
        return UserDefaults.standard.bool(forKey: "ringow.com.kwuikai.displaymode.key")
    }
    
    static func setDisplayMode(_ isDark: Bool) {
        UserDefaults.standard.set(isDark, forKey: "ringow.com.kwuikai.displaymode.key")
    }
    
    static func getModelConfig() -> GenerationConfig? {
        if let config = UserDefaults.standard.retrieve(object: PlainConfig.self, fromKey: "ringow.com.kwuikai.modelconf.key") {
            return GenerationConfig(
                temperature: config.temperature,
                topP: config.topP,
                topK: Int(config.topK),
                candidateCount: Int(config.candidateCount),
                maxOutputTokens: Int(config.maxOutputTokens),
                stopSequences: config.stopSequences)
        }
        return nil
    }
    
    static func setModelConfig(_ conf: PlainConfig) {
        UserDefaults.standard.save(customObject: conf, inKey: "ringow.com.kwuikai.modelconf.key")
    }
    
    static func getModelName() -> String? {
        return UserDefaults.standard.string(forKey: "ringow.com.kwuikai.modelName.key")
    }
    
    static func setModelName(_ str: String) {
        UserDefaults.standard.set(str, forKey: "ringow.com.kwuikai.modelName.key")
    }
    
}
