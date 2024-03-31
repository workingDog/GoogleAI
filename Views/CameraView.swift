//
//  CameraView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2024/03/19.
//

import Foundation
import SwiftUI
import PhotosUI


struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImages: [ImageItem]
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: CameraView
    
    init(picker: CameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImages = [ImageItem(uimage: selectedImage)]
        self.picker.dismiss()
    }
}
