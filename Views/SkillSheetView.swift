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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AiManager.self) private var aiManager
    @Environment(InterfaceManager.self) private var interface
    
    @Query private var allSkills: [SkillModel]
    
    @State private var selectedSkillID: String?
    @State private var originalSkill = SkillModel(name: "Empty", skill: "")
    @State private var editMode: EditMode = .inactive
    @FocusState private var focusedSkillID: String?
    
    @AppStorage(SKILLKEY) private var storedSkill: String = ""
    
    private var skills: [SkillModel] {
        allSkills.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
    
    private var selectedSkill: SkillModel? {
        guard let selectedSkillID else { return nil }
        return allSkills.first(where: { $0.skillid == selectedSkillID })
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [interface.backColor, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationSplitView {
#if !targetEnvironment(macCatalyst)
                Text(aiManager.currentSkill.name)
#endif
                List(selection: $selectedSkillID) {
                    ForEach(skills) { skill in
                        SkillRowView(
                            skill: skill,
                            isEditing: editMode == .active,
                            isSelected: selectedSkillID == skill.skillid,
                            focusedSkillID: $focusedSkillID,
                            onSelect: {
                                selectedSkillID = skill.skillid
                            }
                        )
                        .tag(skill.skillid)
                    }
                    .onDelete(perform: deleteSkill)
                }
                .listStyle(.plain)
                .background(.thinMaterial)
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(editMode == .active ? "Done" : "Edit") {
                            editMode = editMode == .active ? .inactive : .active
                        }
                    }
                    
                    ToolbarItem {
                        Button(action: addSkill) {
                            Label("Add Skill", systemImage: "plus")
                        }
                    }
                }
            } detail: {
                if let selectedSkill {
                    SkillDetailsView(skill: selectedSkill)
                } else {
                    SkillDetailsEmptyView()
                }
            }
            
        }
        .onChange(of: focusedSkillID) { _, newValue in
            guard let newValue else { return }
            selectedSkillID = newValue
        }
        .onChange(of: selectedSkillID) { _, _ in
            guard let selectedSkill else { return }
            aiManager.currentSkill = selectedSkill
            storedSkill = selectedSkill.skillid
        }
        .onAppear {
            originalSkill = aiManager.currentSkill
            
            if let stored = allSkills.first(where: { $0.skillid == storedSkill }) {
                selectedSkillID = stored.skillid
            } else if let current = allSkills.first(where: { $0.skillid == aiManager.currentSkill.skillid }) {
                selectedSkillID = current.skillid
            } else {
                selectedSkillID = skills.first?.skillid
            }
        }
        .onDisappear {
            if originalSkill.skillid != aiManager.currentSkill.skillid {
                aiManager.conversations.last?.history = []
            }
        }
    }
    
    private func addSkill() {
        withAnimation {
            let newSkill = SkillModel(
                name: "New skill",
                skill: "---\nname: new_skill\ndescription: Skill description\nversion: 1.0.0\n---\n"
            )
            modelContext.insert(newSkill)
            selectedSkillID = newSkill.skillid
            focusedSkillID = newSkill.skillid
        }
    }
    
    private func deleteSkill(offsets: IndexSet) {
        withAnimation {
            let deletedIDs = offsets.map { skills[$0].skillid }
            
            for index in offsets {
                modelContext.delete(skills[index])
            }
            
            if let selectedSkillID, deletedIDs.contains(selectedSkillID) {
                self.selectedSkillID = skills.enumerated()
                    .filter { !offsets.contains($0.offset) }
                    .map(\.element.skillid)
                    .first
            }
            
            if self.selectedSkillID == nil {
                aiManager.currentSkill = SkillModel(name: "Empty", skill: "")
                storedSkill = ""
            }
        }
    }
}

private struct SkillRowView2: View {
    @Bindable var skill: SkillModel
    let isEditing: Bool
    var focusedSkillID: FocusState<String?>.Binding
    let onSelect: () -> Void

    var body: some View {
        HStack {
            if isEditing {
                TextField("Skill name", text: $skill.name)
                    .focused(focusedSkillID, equals: skill.skillid)
                    .textFieldStyle(.roundedBorder)
                    .onTapGesture {
                        onSelect()
                    }
            } else {
                Text(skill.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}



private struct SkillRowView: View {
    @Bindable var skill: SkillModel
    let isEditing: Bool
    let isSelected: Bool
    var focusedSkillID: FocusState<String?>.Binding
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            if isEditing {
                TextField("Skill name", text: $skill.name)
                    .focused(focusedSkillID, equals: skill.skillid)
                    .textFieldStyle(.roundedBorder)
                    .onTapGesture {
                        onSelect()
                    }
            } else {
                Text(skill.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .background(isSelected ? Color.primary.opacity(0.08) : .clear)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.clear)
        )
    }
}

struct SkillDetailsView: View {
    @Environment(InterfaceManager.self) private var interface
    @Bindable var skill: SkillModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [interface.backColor, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TextEditor(text: $skill.skill)
                .scrollContentBackground(.hidden)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [interface.backColor, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
    }
}

struct SkillDetailsEmptyView: View {
    @Environment(InterfaceManager.self) private var interface
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [interface.backColor, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ContentUnavailableView(
                "No Skill Selected",
                systemImage: "slider.horizontal.3",
                description: Text("Select a skill from the list or create a new one.")
            )
        }
    }
}

