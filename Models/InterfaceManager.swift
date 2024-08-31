//
//  InterfaceManager.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2024/03/10.
//

import Foundation
import SwiftUI
import Observation


@Observable class InterfaceManager {
    
    // UI colors
    var backColor = Color.teal
    var textColor = Color.white
    var questionColor = Color.green
    var answerColor = Color.blue
    var copyColor = Color.red
    var toolsColor = Color.blue
    var selectedColor = ColorType.back
    
    var kwuiklang = "en"
    var isDarkMode = false
    var textSize: Int = 12
    
    
    init() {
        backColor = StoreService.getColor(ColorType.back)
        textColor = StoreService.getColor(ColorType.text)
        questionColor = StoreService.getColor(ColorType.question)
        answerColor = StoreService.getColor(ColorType.answer)
        copyColor = StoreService.getColor(ColorType.copy)
        toolsColor = StoreService.getColor(ColorType.tools)
        
        kwuiklang = StoreService.getLang()
        isDarkMode = StoreService.getDisplayMode()
        textSize = StoreService.getTextSize()
    }

}
