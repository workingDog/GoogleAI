//
//  SkyllDetailView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/05/09.
//
import SwiftUI
import Foundation


struct SkyllDetailView: View {
    let skill: SkillModel
    
    var body: some View {
        MKView(title: skill.name, text: skill.skill)
    }
}

struct SkyllDetailView2: View {
    let skill: SkillModel
    
    @State private var showRaw: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showRaw {
                Text(skill.skill)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            } else {
                MKView(title: skill.name, text: skill.skill)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Picker("", selection: $showRaw) {
                    Text("Text").tag(true)
                    Text("Preview").tag(false)
                }.pickerStyle(.segmented)
                 .frame(width: 200)
            }
        }
    }
}
