//
//  LoginViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
    private let userRepo: UserRepositoryProtocol
    private let appState: AppState
    var email: String = ""
    
    init(appState: AppState) {
        self.appState = appState
        self.userRepo = appState.userRepository
    }
    
    func login() {
        guard !email.isEmpty else {
            print("empty email")
            return
        }

        Task {
            do {
                let model = UserDataModel(
                    id: AppEnvironment.accessToken,
                    email: email,
                    createdAt: .now,
                    hasCompletedOnboarding: false
                )
                try userRepo.save(model)
                await appState.login(model: model)

            } catch {
                print("Failed to save user: \(error)")
            }
        }
    }
}
