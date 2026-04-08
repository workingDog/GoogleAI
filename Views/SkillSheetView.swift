//
//  SkillSheetView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/04/06.
//
import Foundation
import SwiftUI
import SwiftData


struct SkillSheetView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @Query(sort: \SkillModel.name, order: .reverse) var allSkills: [SkillModel]
    
    @State private var skillSelected: SkillModel?
    @State private var originalSkill: SkillModel = SkillModel(name: "Empty", skill: "")
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
                .listStyle(.plain)
                .background(.thinMaterial)
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
            originalSkill = aiManager.currentSkill
            if let thisSkill = allSkills.first(where: { $0.skillid == storedSkill }) {
                skillSelected = thisSkill
            }
        }
        .onDisappear {
            // if the skill has changed, reset the history
            if originalSkill.skillid != aiManager.currentSkill.skillid {
                aiManager.conversations.last?.history = []
            }
        }
    }
    
    private func addSkill() {
        withAnimation {
            modelContext.insert(SkillModel(name: "New skill", skill: "---\nname: new_skill\ndescription: Skill description\nversion: 1.0.0\n---\n"))
        }
    }

    private func deleteSkill(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(allSkills[index])
            }
            skillSelected = nil
            aiManager.currentSkill = SkillModel(name: "Empty", skill: "")
        }
    }
}

struct SkillDetailsView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    var skill: SkillModel?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [interface.backColor, .white]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea(.all)
            
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
    
}
