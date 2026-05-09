//
//  SkillSheetView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/04/06.
//
import Foundation
import SwiftUI
import SwiftData
import MarkdownUI


struct SkillSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AiManager.self) private var aiManager
    @Environment(InterfaceManager.self) private var interface
    
    @Query private var allSkills: [SkillModel]
    
    @State private var selectedSkillID: String?
    @State private var originalSkill = SkillModel(name: "Empty", skill: "")
    @State private var viewMarkdown: Bool = true
    @State private var editMode: EditMode = .inactive
    @State private var showSearchSheet = false
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
        NavigationSplitView {
            sidebar
                .toolbar {
                    sidebarToolbar()
                }
        } detail: {
            Group {
                if let selectedSkill {
                    SkillDetailsView(skill: selectedSkill, viewMarkdown: $viewMarkdown)
                } else {
                    SkillDetailsEmptyView()
                }
            }
            .toolbar {
                detailToolbar()
            }
        }
        .onChange(of: focusedSkillID) { _, newValue in
            guard let newValue else { return }
            selectedSkillID = newValue
        }
        .onChange(of: selectedSkillID) {
            if selectedSkillID == nil {
                aiManager.currentSkill = SkillModel(name: "Empty", skill: "")
                storedSkill = aiManager.currentSkill.skillid
            } else {
                if let skillSelected = selectedSkill {
                    aiManager.currentSkill = skillSelected
                    storedSkill = skillSelected.skillid
                }
            }
        }
        .onAppear {
            originalSkill = aiManager.currentSkill
            
#if targetEnvironment(macCatalyst)
            if let stored = allSkills.first(where: { $0.skillid == storedSkill }) {
                selectedSkillID = stored.skillid
            } else if let current = allSkills.first(where: { $0.skillid == aiManager.currentSkill.skillid }) {
                selectedSkillID = current.skillid
            } else {
                selectedSkillID = skills.first?.skillid
            }
#endif
        }
        .onDisappear {
            if originalSkill.skillid != aiManager.currentSkill.skillid {
                aiManager.conversations.last?.history = []
            }
        }
    }
    
    @ToolbarContentBuilder
    func detailToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Picker("", selection: $viewMarkdown) {
                Text("Edit").tag(false)
                Text("Preview").tag(true)
            }.pickerStyle(.segmented)
             .frame(width: 200)
        }
    }
    
    @ToolbarContentBuilder
    func sidebarToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Done") {
                dismiss()
            }.buttonStyle(.bordered).fixedSize()
        }
        
        ToolbarItem(placement: .automatic) {
            Button("Search Skyll") {
                showSearchSheet = true
            }.buttonStyle(.bordered).fixedSize()
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(editMode == .active ? "Done" : "Manage") {
                editMode = editMode == .active ? .inactive : .active
            }.buttonStyle(.bordered).fixedSize()
        }
        
        ToolbarItem {
            Button(action: addSkill) {
                Label("Add Skill", systemImage: "plus")
            }.buttonStyle(.bordered).fixedSize()
        }
    }
    
    @ViewBuilder
    private var sidebar: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [interface.backColor, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            List(selection: $selectedSkillID) {
                ForEach(skills) { skill in
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            if selectedSkillID == skill.skillid {
                                selectedSkillID = nil
                            } else {
                                selectedSkillID = skill.skillid
                            }
                        } label: {
                            Image(systemName: selectedSkillID == skill.skillid ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedSkillID == skill.skillid ? Color.green : Color.blue)
                                .font(.title3)
                        }.buttonStyle(.plain)
                        Spacer()
                        SkillRowView(
                            skill: skill,
                            isEditing: editMode == .active,
                            focusedSkillID: $focusedSkillID,
                            onSelect: {
                                selectedSkillID = skill.skillid
                            }
                        )
                        Spacer()
                    }
                    .tag(skill.skillid)
                    .padding(10)
                    .listRowBackground(Color.green.opacity(0.2))
                }
                .onDelete(perform: deleteSkill)
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .padding(.vertical, 15)
            .environment(\.editMode, $editMode)
            
        }
        .sheet(isPresented: $showSearchSheet) {
            SkyllSearchView(selectedSkillID: $selectedSkillID)
                .environment(aiManager)
                .presentationDetents([.large])
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

private struct SkillRowView: View {
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

struct SkillDetailsView: View {
    @Environment(InterfaceManager.self) private var interface
    @Bindable var skill: SkillModel
    @Binding var viewMarkdown: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [interface.backColor, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if viewMarkdown {
                ScrollView {
                    Markdown(skill.skill)
                        .markdownTextStyle {
                            FontFamilyVariant(.normal)
                            FontSize(CGFloat(interface.textSize))
                            ForegroundColor(.black)
                        }
                        .markdownBlockStyle(\.codeBlock) { configuration in
                            configuration.label
                                .relativeLineSpacing(.em(0.25))
                                .markdownTextStyle {
                                    FontFamilyVariant(.monospaced)
                                    FontSize(CGFloat(interface.textSize))
                                    ForegroundColor(.black)
                                }
                                .padding()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .markdownMargin(top: .zero, bottom: .em(0.8))
                        }
                }
            } else {
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
