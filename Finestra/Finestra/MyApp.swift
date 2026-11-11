import SwiftUI

@main struct MyApp: App {
    @State private var appState: AppState

    init() {
        let databaseManager: DatabaseManagerProtocol
        do {
            databaseManager = try DatabaseManager(
                modelTypes: [
                    SessionDatabaseModel.self,
                    UserDatabaseModel.self
                ]
            )
        } catch {
            fatalError("Unable to initialize the application database: \(error)")
        }

        _appState = State(
            initialValue: AppState(
                authManager: AuthManager(),
                userRepository: UserRepository(
                    databaseManager: databaseManager,
                    environment: .live
                ),
                sessionRepository: SessionRepository(
                    databaseManager: databaseManager
                )
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
        }
    }
}
