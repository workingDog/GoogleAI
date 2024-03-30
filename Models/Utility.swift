//
//  Utility.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/26.
//

import Foundation
import SwiftUI
import UIKit



extension UIImage {
    
    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func resizeWithRatio(size: CGSize) -> UIImage {
        // the scale factor that preserves aspect ratio
        let widthRatio = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        let scale = min(widthRatio, heightRatio)

        // the new image size that preserves aspect ratio
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        // the resized UIImage
        let renderer = UIGraphicsImageRenderer(size: newSize)
        // draw it
        let newImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return newImage
    }
    
}

extension UserDefaults {

   func save<T: Encodable>(customObject object: T, inKey key: String) {
       if let encoded = try? JSONEncoder().encode(object) {
           self.set(encoded, forKey: key)
       }
   }

   func retrieve<T: Decodable>(object type: T.Type, fromKey key: String) -> T? {
       if let data = self.data(forKey: key) {
           if let object = try? JSONDecoder().decode(type, from: data) {
               return object
           } else {
               print("Could not decode object")
               return nil
           }
       } else {
           print("Could not find key")
           return nil
       }
   }

}

enum ColorType: String, CaseIterable {
    case back, text, question, answer, copy, tools
}
  
enum ModeType: String, CaseIterable {
    case image, chat, camera
}

enum CopyType: String, CaseIterable {
    case image, text
}

extension Animation {
    func reverse(on: Binding<Bool>, delay: Double) -> Self {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            on.wrappedValue = false /// Switch off after `delay` time
        }
        return self
    }
}

public struct CustomTextFieldStyle : TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.callout)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue, lineWidth: 2))
    }
}

func fetchImage(url: URL) async -> UIImage? {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let img = UIImage(data: data) {
            return img
        }
    } catch {
        print(error)
    }
    return nil
}

struct IconRotateStyle: ProgressViewStyle {
    @State var isAnimating = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Image("kwuikaiicon").resizable().frame(width: 35, height: 35)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0.0))
                .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear {
                    isAnimating = true
                }
        }
    }
}
