//
//  SkillSheetView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/04/06.
//
import Foundation
import SwiftUI
import GeminiKit
import SwiftData


struct SkillSheetView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @Query(sort: \SkillModel.name, order: .reverse) var allSkills: [SkillModel]
    
    @State private var skillSelected: SkillModel?
    @State private var editMode: EditMode = .inactive
    
    @AppStorage(SKILLKEY) var storedSkill: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [interface.backColor, .white]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea(.all)
            
            NavigationSplitView {
                List(selection: $skillSelected) {
                    ForEach(allSkills) { skill in
                        @Bindable var skill = skill
                        
                        HStack {
                            if editMode == .active {
                                TextField("Skill name", text: $skill.name)
                            } else {
                                Text(skill.name)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            skillSelected = skill
                        }
                        .tag(skill)
                    }
                    .onDelete(perform: deleteSkill)
                }
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            editMode = (editMode == .active) ? .inactive : .active
                        } label: {
                            Text(editMode == .active ? "Done" : "Edit")
                        }
                    }
                    ToolbarItem {
                        Button(action: addSkill) {
                            Label("Add Skill", systemImage: "plus")
                        }
                    }
                }
            } detail: {
                SkillDetailsView(skill: skillSelected)
            }
        }
        .onChange(of: skillSelected) {
            if let skillSelected {
                aiManager.currentSkill = skillSelected
                storedSkill = skillSelected.skillid
            }
        }
        .onAppear {
            if let thisSkill = allSkills.first(where: { $0.skillid == storedSkill }) {
                skillSelected = thisSkill
            }
        }
    }
    
    private func addSkill() {
        withAnimation {
            modelContext.insert(SkillModel.NewSkill)
        }
    }

    private func deleteSkill(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(allSkills[index])
            }
            skillSelected = nil
            aiManager.currentSkill = SkillModel.Empty
        }
    }
}

struct SkillDetailsView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    var skill: SkillModel?
    
    var body: some View {
            if let skill {
                @Bindable var skill = skill
                
                TextEditor(text: $skill.skill)
                    .scrollContentBackground(.hidden)
                    .background(LinearGradient(gradient: Gradient(colors: [interface.backColor, .white]), startPoint: .top, endPoint: .bottom))
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("no skills")
            }

    }
    
}
