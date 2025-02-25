//
//  PrimaryButtonStyle.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 24/02/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if isEnabled {
                configuration.label
            } else {
                ProgressView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background(Color.accentColor)
        .clipShape(.rect(cornerRadius: 10))
        .animation(.default, value: isEnabled)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}
