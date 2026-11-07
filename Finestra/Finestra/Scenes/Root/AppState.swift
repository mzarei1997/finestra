//
//  AppState.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class AppState {
    
    private(set) var appRoute: AppRoute = .splash
    private let authManager: AuthManagerProtocol
    private(set) var userRepository: UserRepositoryProtocol
    let sessionRepository: SessionRepositoryProtocol
    private var hasInitialized = false
    
    init(
        authManager: AuthManagerProtocol,
        userRepository: UserRepositoryProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.authManager = authManager
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
    }
    
    func initialize() async {
        guard !hasInitialized else { return }
        hasInitialized = true
        let start = ContinuousClock.now
        await authManager.restoreSession()
        if !authManager.isAuthenticated {
            do {
                if let user = try userRepository.loadUser() {
                    _ = await authManager.login(model: user)
                }
            } catch {
                report(error, context: "Unable to restore the saved user")
            }
        }
        let elapsed = start.duration(to: .now)
        let minimumDuration = Duration.seconds(3)
        if elapsed < minimumDuration {
            try? await Task.sleep(for: minimumDuration - elapsed)
        }
        resolveRouting()
    }
    
    private func resolveRouting() {
        guard authManager.isAuthenticated else {
            appRoute = .welcome
            return
        }

        do {
            appRoute = try userRepository.hasCompletedOnboarding() ? .menu : .onboarding
        } catch {
            report(error, context: "Unable to resolve the application route")
        }
    }
    
    func login(model: UserDataModel) async {
        let result = await authManager.login(model: model)
        if result {
            resolveRouting()
        } else {
            print("Unable to authenticate the user")
        }
    }
    
    func showLogin() {
        do {
            guard let user = try userRepository.loadUser() else {
                appRoute = .login
                return
            }

            Task {
                if await authManager.login(model: user) {
                    resolveRouting()
                } else {
                    appRoute = .login
                }
            }
        } catch {
            report(error, context: "Unable to load the saved user")
            appRoute = .login
        }
    }
    
    func loggedIn() {
        resolveRouting()
    }
    
    func showOnboarding() {
        appRoute = .onboarding
    }
    
    func finishedOnboarding() {
        do {
            try userRepository.completedOnboarding()
            resolveRouting()
        } catch {
            report(error, context: "Unable to complete onboarding")
        }
    }

    private func report(_ error: Error, context: String) {
        print("\(context): \(error.localizedDescription)")
    }
}
