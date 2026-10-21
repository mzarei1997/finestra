//
//  UserRepository.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func hasCompletedOnboarding() -> Bool
    func completedOnboarding()
}

// for multi-device apps, we save this state on server and check with authentication api calls
final class UserRepository: UserRepositoryProtocol {
    
    private let defaults = UserDefaults.standard
    private let key = "hasCompletedOnboarding"
    
    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: key)
    }
    
    func completedOnboarding() {
        defaults.set(true, forKey: key)
    }
}
