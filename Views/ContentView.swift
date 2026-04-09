//
//  ContentView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
//
import Foundation
import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @State private var showAlert = false
    @State private var showSettings = false
    @State private var showSkill = false
    @FocusState var focusValue: Bool
    
    @AppStorage(SKILLKEY) var storedSkill: String = ""
    
    @Query(sort: \SkillModel.name, order: .reverse) var allSkills: [SkillModel]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [interface.backColor, .white]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea(.all)
            .onTapGesture { focusValue = false }
            VStack(spacing: 3) {
                AIToolbar().padding(5)
                MainView(focusValue: $focusValue).offset(x: 0, y: -16)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingView()
                .environment(aiManager)
                .environment(interface)
        }
        .fullScreenCover(isPresented: $showSkill) {
            SkillSheetView()
                .environment(aiManager)
                .environment(interface)
        }
        .alert("Google AI Key is not set", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text("Tap the gear symbol ⚙︎ to enter your key")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showAlert = StoreService.getKey() == nil
            }

            // initial example skills
            if allSkills.isEmpty {
                modelContext.insert(SkillModel(name: "Empty", skill: ""))
                modelContext.insert(SkillModel(name: "StarterSkill", skill: StarterSkill))
                modelContext.insert(SkillModel(name: "GeneralTask", skill: GeneralTask))
                modelContext.insert(SkillModel(name: "SkillCreator", skill: SkillCreatorAgent))
            }

            if let skill = allSkills.first(where: { $0.skillid == storedSkill }) {
                aiManager.currentSkill = skill
            }

//            let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
//            print("---> \(appSupportDir)")

        }
        
        // todo save the info/chat history when going into background
//        .onChange(of: scenePhase) {
//            switch scenePhase {
//            case .active:
//                print("-----> active")
//            case .inactive:
//                print("-----> inactive")
//            case .background:
//                print("-----> background")
//            @unknown default:
//                print("-----> default")
//            }
//        }
    }

    @ViewBuilder
    func AIToolbar() -> some View {
        VStack {
            HStack {
                LeftButtons()
                Spacer()
                SettingsButton()
            }
            .foregroundStyle(interface.toolsColor)
            .font(.title)
            .padding(.bottom, 10)
            
            ModesButton().padding(8)
            
            WavyLineView(height: 10.0, freq: 0.2, lineWidth: 2, lineLength: 333)
                .offset(x: -15, y: 0)
                .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    func ModesButton() -> some View {
        @Bindable var aiManager = aiManager
        Picker("", selection: $aiManager.selectedMode) {
            Image(systemName: "ellipsis.message").tag(ModeType.chat)
            Image(systemName: "photo").tag(ModeType.image)
            Image(systemName: "camera.shutter.button").tag(ModeType.camera)
        }
        .pickerStyle(.segmented)
        .foregroundStyle(interface.toolsColor, .blue)
        .frame(width: 140)
        .scaleEffect(1.3)
    }
    
    @ViewBuilder
    func SkillButton() -> some View {
        Button(action: { showSkill = true }) {
            Image(systemName: "sparkles.rectangle.stack")
        }
    }

    @ViewBuilder
    func SettingsButton() -> some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape")
        }
    }

    @ViewBuilder
    func LeftButtons() -> some View {
        HStack (spacing: 10){
            Button(action: { aiManager.conversations.removeAll() }) {
                Image(systemName: "trash")
            }
            ShareLinkView()
            SkillButton()
        }
    }
    
    @ViewBuilder
    func ShareLinkView() -> some View {
        Group {
            if let uiimg = aiManager.shareItem as? UIImage {
                let image = Image(uiImage: uiimg)
                ShareLink(item: image, preview: SharePreview("picture", image: image)) {
                    Image(systemName:"square.and.arrow.up")
                }
            } else {
                let txt = aiManager.shareItem as? String ?? "nothing to share"
                ShareLink(item: txt) {
                    Image(systemName:"square.and.arrow.up")
                }
            }
        }
    }
    
}
