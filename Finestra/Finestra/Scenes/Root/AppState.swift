//
//  AppState.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

@Observable
@MainActor
final class AppState {
    
    private(set) var appRoute: AppRoute = .splash
    private let authManager: AuthManagerProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        authManager: AuthManagerProtocol,
        userRepository: UserRepositoryProtocol
    ) {
        self.authManager = authManager
        self.userRepository = userRepository
    }
    
    func initialize() async {
        await authManager.restoreSession()
        resolveRouting()
    }
    
    private func resolveRouting() {
        guard authManager.isAuthenticated else {
            appRoute = .welcome
            return
        }
        
        if userRepository.hasCompletedOnboarding() {
            appRoute = .home
        } else {
            appRoute = .onboarding
        }
    }
    
    func login(model: LoginModel) async {
        let result = await authManager.login(model: model)
        if result {
            appRoute = .onboarding
        }
    }
    
    func showLogin() {
        appRoute = .login
    }
    
    func loggedIn() {
        resolveRouting()
    }
    
    func showOnboarding() {
        appRoute = .onboarding
    }
}
