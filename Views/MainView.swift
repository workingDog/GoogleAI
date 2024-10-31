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
    @State private var selectedImages: [ImageItem] = []
    @State private var photoItems: [PhotosPickerItem] = []
    
    var body: some View {
        @Bindable var aiManager = aiManager
        ZStack {
            Color.white.opacity(0.001)
                .ignoresSafeArea(.all)
                .onTapGesture { focusValue = false }
            VStack(spacing: 1) {
                InputView()
                CompletionView(isThinking: $isThinking)
                Spacer()
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItems)
        .task(id: photoItems) { 
            if !photoItems.isEmpty {
                var tempArr: [UIImage] = []
                for item in photoItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiimg = UIImage(data: data) {
                        tempArr.append(uiimg)
                    }
                }
                // reduce the size of the images
                let smallerImg = tempArr.compactMap{$0.resizeImageTo(size: CGSize(width: 333, height: 333))}
                // update/onChange selectedImages only once
                selectedImages = smallerImg.map{ImageItem(uimage: $0)}
                photoItems.removeAll()
            }
        }
        .alert("No results available", isPresented: $aiManager.errorDetected) {
            Button("OK") { }
        } message: { Text("Check your api key \n or account limit") }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(selectedImages: $selectedImages)
        }
        .onChange(of: selectedImages) {
            if !selectedImages.isEmpty {
                doAsk()
            }
        }
     //   .onAppear {
          //  focusValue = true
     //   }
    }
    
    @ViewBuilder
    func InputView() -> some View {
        VStack (spacing: 4) {
            Button(action: {
                isPressed.toggle()
                focusValue = false
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                        .foregroundStyle(interface.textColor)
                        .background(isPressed ? interface.copyColor : interface.questionColor)
                        .animation(.easeInOut(duration: 0.2)
                            .reverse(on: $isPressed, delay: 0.2), value: isPressed)
                        .clipShape(Circle())

                    if isThinking {
                        ProgressView().progressViewStyle(IconRotateStyle()).offset(y: 24)
//                        Image(systemName: "gear.circle")
//                         .resizable()
//                         .foregroundStyle(interface.toolsColor.opacity(0.4))
//                        .frame(width: 88, height: 88)
//                        .rotationEffect(Angle(degrees: isPressed ? 360 : 0))
//                        .animation(Animation.linear(duration: 3).repeatForever(autoreverses: false), value: isPressed)
                    }
                }
            }
            .disabled(text.isEmpty ? true : false)
            .shadow(radius: 10)
       //     .overlay(Circle().stroke(interface.toolsColor, lineWidth: 4))

            ChatBubble(direction: .left) {
       //     LeftBubble {
                TextEditor(text: $text)
                    .focused($focusValue)
                    .frame(height: 110)
                    .font(.system(size: CGFloat(interface.textSize)))
                    .padding(.all, 10)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(interface.textColor)
                    .background(interface.questionColor)
                    .overlay(
                        Text("Type here first...")
                            .font(.system(size: CGFloat(interface.textSize)))
                            .foregroundStyle(.black)
                            .opacity(text.isEmpty && !focusValue ? 1 : 0)
                            .onTapGesture {
                                focusValue = true
                            }
                    )
            }
        }
    }
    
    func doAsk() {
        Task {
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                isThinking = true
                if !selectedImages.isEmpty, aiManager.selectedMode != .chat {
                    await aiManager.getResponse(from: text, images: selectedImages)
                } else {
                    await aiManager.getResponse(from: text)
                }
                isThinking = false
                text = ""
            }
        }
    }
   
}
