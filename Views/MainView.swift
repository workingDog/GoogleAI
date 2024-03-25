//
//  MainView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/04/11.
//

import Foundation
import SwiftUI
import PhotosUI


struct MainView: View {
    @Environment(AiManager.self) var aiManager
    @Environment(InterfaceManager.self) var interface
    
    @State private var text = ""
    @State private var isThinking = false
    @State private var isPressed = false
    
    @FocusState.Binding var focusValue: Bool
    
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        @Bindable var aiManager = aiManager
        ZStack {
            Color.white.opacity(0.001).ignoresSafeArea(.all)
                .onTapGesture { focusValue = false }
            VStack(spacing: 1) {
                inputView
                CompletionView(isThinking: $isThinking)
                Spacer()
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem)
        .onChange(of: photoItem) {
            if photoItem != nil {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        selectedImage = UIImage(data: data)
                        photoItem = nil
                    } else {
                        print("Failed to load the image")
                    }
                }
            }
        }
        .alert("No results available", isPresented: $aiManager.errorDetected) {
            Button("OK") { }
        } message: { Text("Check your api key \n or account limit") }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if selectedImage != nil {
                doAsk()
            }
        }
    }
    
    var inputView: some View {
        VStack (spacing: 4) {
            Button(action: {
                isPressed.toggle()
                focusValue = false
                if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    switch aiManager.selectedMode {
                        case .camera: showCamera = true
                        case .image: showPhotoPicker = true
                        case .chat: doAsk()
                    }
                } else {
                    text = ""
                }
            }) {
                ZStack {
                    Text(aiManager.selectedMode == .chat ? "Chat" : aiManager.selectedMode == .image ? "Image" : "Camera")
                        .font(Font.custom("Didot-Italic", size: 17))
                        .frame(width: 88, height: 88)
                        .offset(y: -6)
                        .foregroundColor(interface.textColor)
                        .background(isPressed ? interface.copyColor : interface.questionColor)
                        .animation(.easeInOut(duration: 0.2)
                            .reverse(on: $isPressed, delay: 0.2), value: isPressed)
                        .clipShape(Circle())

                    if isThinking {
                        ProgressView().progressViewStyle(IconRotateStyle()).offset(y: 24)
                    }
                }
            }
            .shadow(radius: 10)
       //     .overlay(Circle().stroke(interface.toolsColor, lineWidth: 4))

            ChatBubble(direction: .left) {
       //     LeftBubble {
                TextEditor(text: $text)
                    .focused($focusValue)
                    .frame(height: 110)
                    .font(.callout)
                    .padding(.all, 10)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(interface.textColor)
                    .background(interface.questionColor)
                    .overlay(
                        Text("Type here first...")
                            .foregroundColor(.black)
                            .opacity(text.isEmpty && !focusValue ? 1 : 0)
                            .onTapGesture {
                                focusValue = true
                            }
                    )
            }
        }
    }
    
    func doAsk() {
        isThinking = true
        Task { @MainActor in   // <--- do task on the main thread
            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                if let img = selectedImage, aiManager.selectedMode != .chat {
                    await aiManager.getResponse(from: text, images: [img])
                } else {
                    await aiManager.getResponse(from: text)
                }
                isThinking = false
                text = ""
            }
        }
    }
    
}
