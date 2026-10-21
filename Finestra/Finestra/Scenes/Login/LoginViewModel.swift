//
//  LoginViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

@MainActor
@Observable
final class LoginViewModel {
    private var appState: AppState
    var email: String = ""
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func login() {
        guard !email.isEmpty else {
            print("empty email")
            return
        }
        Task {
            await appState.login(
                model: LoginModel(email: email)
            )
        }
    }
}
