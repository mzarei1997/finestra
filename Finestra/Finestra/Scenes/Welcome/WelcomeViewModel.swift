import Foundation
import Observation

@MainActor
@Observable
final class WelcomeViewModel {
    private let appState: AppState
    let model = WelcomeModel()

    init(appState: AppState) {
        self.appState = appState
    }

    func didTapGetStarted() {
        appState.showLogin()
    }
}
