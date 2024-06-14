//
//  ContentView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
//
import Foundation
import SwiftUI
import GoogleGenerativeAI



struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @State private var showAlert = false
    @State private var showSettings = false
    @FocusState var focusValue: Bool
    
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [interface.backColor, .white]),
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea(.all)
            .onTapGesture { focusValue = false }
            VStack(spacing: 3) {
                theToolbar.padding(5)
                MainView(focusValue: $focusValue).offset(x: 0, y: -16)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingView()
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
    var theToolbar: some View {
        VStack {
            HStack {
                leftButtons
                Spacer()
                modesButton
                Spacer()
                settingsButton
            }
            .foregroundStyle(interface.toolsColor)
            .font(.title)
            .padding(.bottom, 8)
            
            WavyLineView(height: 10.0, freq: 0.2, lineWidth: 2, lineLength: 333)
                .offset(x: -10, y: 0)
                .padding(.vertical, 10)
        }
    }
    
    @ViewBuilder
    var modesButton: some View {
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
    var settingsButton: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape")
        }
    }
    
    @ViewBuilder
    var leftButtons: some View {
        HStack (spacing: 10){
            Button(action: { aiManager.conversations.removeAll() }) {
                Image(systemName: "trash")
            }
            shareLinkView()
        }
    }
    
    @ViewBuilder
    func shareLinkView() -> some View {
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
