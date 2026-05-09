//
//  SkyllSearchView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/05/09.
//
import SwiftUI
import SwiftData


struct SkyllSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AiManager.self) private var aiManager
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage(SKILLKEY) private var storedSkill: String = ""
    
    @Binding var selectedSkillID: String?
    
    @State private var isThinking: Bool = false
    @State private var selectedSkill: SkillModel?
    @State private var skills: [SkillModel] = []
    @State private var query = ""

    @Query private var allSkills: [SkillModel]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TextField("Search for skills...", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit {
                            startSearch()
                        }
                    
                    Button("Search") {
                        startSearch()
                    }.buttonStyle(.borderedProminent)
                }

                if isThinking {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
                if let error = SkyllService.shared.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                }
                
                List {
                    ForEach(skills) { skill in
                        HStack(alignment: .top, spacing: 12) {
                            Button {
                                if selectedSkill == skill {
                                    selectedSkill = nil    // de-select
                                } else {
                                    selectedSkill = skill  // select
                                    updateSelection()
                                }
                            } label: {
                                Image(systemName: selectedSkill == skill ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedSkill == skill ? Color.green : Color.blue)
                                    .font(.title3)
                            }.buttonStyle(.plain)
                            Spacer()
                            NavigationLink {
                                SkyllDetailView(skill: skill)
                            } label: {
                                Text(skill.name)
                            }
                            Spacer()
                        }
                        .padding(10)
                        .listRowBackground(Color.green.opacity(0.2))
                    }
                    .onDelete(perform: deleteSkills)
                }
            }
            .navigationTitle("Skyll Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }.buttonStyle(.bordered).fixedSize()
                }
            }
        }
    }

    private func updateSelection() {
        if let selectedSkill {
            selectedSkillID = selectedSkill.skillid
            aiManager.currentSkill = selectedSkill
            storedSkill = selectedSkill.skillid
            modelContext.insert(selectedSkill)
        } else {
            selectedSkillID = nil
            aiManager.currentSkill = nil
            storedSkill = ""
        }
    }
    
    private func startSearch() {
        Task {
            isThinking = true
            skills = try await SkyllService.shared.searchSkills(query: query)
            isThinking = false
        }
    }
    
    private func deleteSkills(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(skills[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete skills: \(error)")
        }
    }

}

