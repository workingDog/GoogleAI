//
//  MKView.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/05/09.
//
import SwiftUI
import MarkdownUI


struct MKView: View {
    @Environment(InterfaceManager.self) var interface
    
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            ScrollView {
                Markdown(text)
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
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }
}

