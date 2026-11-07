//
//  UserDatabaseModel.swift
//  Finestra
//

import SwiftData
import SwiftUI

@Model
final class UserDatabaseModel {
    @Attribute(.unique) var id: String
    var email: String
    var createdAt: Date
    var hasCompletedOnboarding: Bool

    init(
        id: String,
        email: String,
        createdAt: Date,
        hasCompletedOnboarding: Bool
    ) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    static func makeDbModel(from user: UserDataModel) -> UserDatabaseModel {
        UserDatabaseModel(
            id: user.id,
            email: user.email,
            createdAt: user.createdAt,
            hasCompletedOnboarding: user.hasCompletedOnboarding
        )
    }
    
}

struct UserDataModel {
    let id: String
    var email: String
    let createdAt: Date
    var hasCompletedOnboarding: Bool
    
    static func makeModel(from user: UserDatabaseModel) -> UserDataModel {
        UserDataModel(
            id: user.id,
            email: user.email,
            createdAt: user.createdAt,
            hasCompletedOnboarding: user.hasCompletedOnboarding
        )
    }
}
