//
//  WelcomeView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
            Button("Login / Sign Up") {
                appState.showLogin()
            }
            Button("Continue without account") {
                appState.showOnboarding()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
