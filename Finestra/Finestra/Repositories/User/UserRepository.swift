//
//  UserRepository.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

@MainActor
protocol UserRepositoryProtocol {
    func hasCompletedOnboarding() throws -> Bool
    func completedOnboarding() throws
    func loadUser() throws -> UserDataModel?
    func save(_ user: UserDataModel) throws
}


// for multi-device apps, we save this state on server and check with authentication api calls
@MainActor
final class UserRepository: UserRepositoryProtocol {

    private let databaseManager: DatabaseManagerProtocol
    private let environment: AppEnvironment

    init(
        databaseManager: DatabaseManagerProtocol,
        environment: AppEnvironment = .live
    ) {
        self.environment = environment
        self.databaseManager = databaseManager
    }

    func hasCompletedOnboarding() throws -> Bool {
        let user = try loadUser()
        return user?.hasCompletedOnboarding ?? false
    }

    func completedOnboarding() throws {
        guard var user = try loadUser() else {
            throw NSError(
                   domain: "UserRepository",
                   code: 1,
                   userInfo: [NSLocalizedDescriptionKey: "Unable to load user."]
               )
        }
        user.hasCompletedOnboarding = true
        try databaseManager
            .update(
                UserDatabaseModel.self,
                primaryKey: user.id,
                keyPath: \.id,
                updates: { user in
                    user.hasCompletedOnboarding = true
                })
    }
    
    func loadUser() throws -> UserDataModel? {
        guard let dbUser = try databaseManager.fetch(
            UserDatabaseModel.self,
            primaryKey: AppEnvironment.accessToken,
            keyPath: \.id
        ) else {
            return nil
        }
        return UserDataModel.makeModel(from: dbUser)
    }

    func save(_ user: UserDataModel) throws {
         let dbModel = UserDatabaseModel.makeDbModel(from: user)
         try databaseManager.add(dbModel)
     }
}
