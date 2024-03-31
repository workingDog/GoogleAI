//
//  CustomSecureField.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2023/03/27.
//

import Foundation
import SwiftUI

// from: https://stackoverflow.com/questions/70491417/toggle-issecuretextentry-in-swiftui-for-securefield


struct CustomSecureField: View {
    @Binding var backColor: Color
    @Binding var password: String
    
    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                if password.isEmpty {
                    HStack {
                        Text("")
                        Spacer()
                    }
                }
                ZStack {
                    TextField("", text: $password)
                    .frame(maxHeight: .infinity)
                    .opacity(isPasswordVisible ? 1 : 0)
                    
                    SecureField("", text: $password)
                    .frame(maxHeight: .infinity)
                    .opacity(isPasswordVisible ? 0 : 1)
                }
            }
            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
            }
            .padding(.trailing, 5)
        }
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .background(backColor)
        .cornerRadius(5)
    }
    
}
