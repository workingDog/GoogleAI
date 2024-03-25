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
    
    @State private var showSettings = false
    @State private var showShareSheet = false

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
        .onChange(of: aiManager.selectedMode) {
            aiManager.updateModel()
        }
        .sheet(isPresented: $showSettings) {
            SettingView()
                .environment(aiManager)
                .environment(interface)
        }
        .sheet(isPresented: $showShareSheet) {
            if let txt = aiManager.selectedConversation?.answers.compactMap({$0.text}).first {
                ShareSheet(activityItems: [txt])
            } else {
                if let imgages = aiManager.selectedConversation?.answers.compactMap({$0.uimage}) {
                    ShareSheet(activityItems: imgages)
                } else {
                    ShareSheet(activityItems: ["nothing to share"])
                }
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

    var theToolbar: some View {
        VStack {
            HStack {
                leftButtons
                Spacer()
                modesButton
                Spacer()
                settingsButton
            }.foregroundColor(interface.toolsColor)
                .font(.title)
                .padding(.bottom, 8)
            
            WavyLineView(height: 10.0, freq: 0.2, lineWidth: 2, lineLength: 333)
                .offset(x: -10, y: 0)
                .padding(.vertical, 10)
        }
    }
    
    var modesButton: some View {
        @Bindable var aiManager = aiManager
        return Picker("", selection: $aiManager.selectedMode) {
            Image(systemName: "ellipsis.message").tag(ModeType.chat)
            Image(systemName: "photo").tag(ModeType.image)
            Image(systemName: "camera.shutter.button").tag(ModeType.camera)
        }.pickerStyle(.segmented)
            .foregroundStyle(interface.toolsColor, .blue)
            .frame(width: 140)
            .scaleEffect(1.3)
    }

    var settingsButton: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape")
        }
    }
    
    var leftButtons: some View {
        HStack (spacing: 10){
            Button(action: { aiManager.conversations.removeAll() }) {
                Image(systemName: "trash")
            }
            Button(action: { showShareSheet = true }) {
                Image(systemName:"square.and.arrow.up")
            }
        }
    }
    
}


