//
//  WavyLineView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2024/03/22.
//

import Foundation
import SwiftUI


struct WavyLineView: View {
    @Environment(InterfaceManager.self) var interface
    
    let height: Double
    let freq: Double
    let lineWidth: CGFloat
    let lineLength: Int
    
    var body: some View {
        Path { path in
            path.move(to: .zero)
            for i in 0...lineLength {
                let x = CGFloat(i) * height
                let y = sin(Double(i) * freq) * height
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        .stroke(interface.toolsColor, lineWidth: lineWidth)
        .frame(maxHeight: height)
    }
}
