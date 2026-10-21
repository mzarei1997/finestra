//
//  PreviewFactory.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation


enum PreviewFactory {
    private static func makeAuthManager() -> AuthManagerProtocol {
        AuthManager()
    }
    
    private static func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository()
    }
    
    private static func makeAppState() -> AppState {
        AppState(authManager: makeAuthManager(), userRepository: makeUserRepository())
    }
    
    static func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(appState: makeAppState())
    }
}
