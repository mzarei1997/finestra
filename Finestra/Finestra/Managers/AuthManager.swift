//
//  AuthManager.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

protocol AuthManagerProtocol {
    var isAuthenticated: Bool { get }
    func login(model: LoginModel) async -> Bool
    func restoreSession() async
}

@Observable
@MainActor
final class AuthManager: AuthManagerProtocol {
 
    private(set) var isAuthenticated = false
    
    func restoreSession() async {
        // check user state with server
        isAuthenticated = false
    }
    
    func login(model: LoginModel) async -> Bool {
        guard !model.email.isEmpty else { // check by server
            isAuthenticated = false
            print("cant be authenticated")
            return false
        }
        isAuthenticated = true
        return true
    }
}
