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
    
    private static func makeDatabaseManager() -> DatabaseManagerProtocol {
        do {
            return try DatabaseManager(modelTypes: [
                UserDatabaseModel.self,
                SessionDatabaseModel.self
            ])
        } catch {
            fatalError("Unable to initialize the preview database: \(error)")
        }
    }

    private static func makeUserRepository() -> UserRepositoryProtocol {
        UserRepository(databaseManager: makeDatabaseManager())
    }
    
    private static func makeAppState() -> AppState {
        let databaseManager = makeDatabaseManager()
        return AppState(
            authManager: makeAuthManager(),
            userRepository: UserRepository(databaseManager: databaseManager),
            sessionRepository: SessionRepository(databaseManager: databaseManager)
        )
    }
    
    static func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(appState: makeAppState())
    }

    static func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(appState: makeAppState())
    }

    static func makeWelcomeViewModel() -> WelcomeViewModel {
        WelcomeViewModel(appState: makeAppState())
    }

    static func makeScheduleViewModel() -> ScheduleViewModel {
        ScheduleViewModel(sessionRepository: makeSessionRepository())
    }

    private static func makeSessionRepository() -> SessionRepositoryProtocol {
        SessionRepository(databaseManager: makeDatabaseManager())
    }

    static func makeMenuViewModel() -> MenuViewModel {
        MenuViewModel(sessionRepository: makeSessionRepository())
    }
    
    static func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(sessionRepository: makeSessionRepository())
    }
    
    static func makeFocusViewModel() -> FocusViewModel {
        FocusViewModel(sessionRepository: makeSessionRepository())
    }
}
