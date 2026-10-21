//
//  AppRootView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        
        Group {
            switch appState.appRoute {
            case .splash:
                ProgressView()
            case .onboarding:
                Text("onboarding")
            case .login:
                LoginView(
                    viewModel: LoginViewModel(
                        appState: appState
                    )
                )
            case .home:
                Text("home")
            case .welcome:
                WelcomeView()
            }
        }
        .task {
            await appState.initialize()
        }
    }
}

#Preview {
    AppRootView()
}
