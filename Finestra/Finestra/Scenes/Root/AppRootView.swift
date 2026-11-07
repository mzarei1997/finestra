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
                SplashView(viewModel: SplashViewModel())
            case .onboarding:
                OnboardingView(
                    viewModel: OnboardingViewModel(
                        appState: appState
                    )
                )
            case .login:
                LoginView(
                    viewModel: LoginViewModel(
                        appState: appState
                    )
                )
            case .menu:
                MenuView(viewModel: MenuViewModel(
                    sessionRepository: appState.sessionRepository
                ))
            case .welcome:
                WelcomeView(
                    viewModel: WelcomeViewModel(appState: appState)
                )
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
