import Foundation
import Observation

@MainActor
@Observable
final class SplashViewModel {
    let model = SplashModel(title: "Finestra", subtitle: "Find your next move")
}
