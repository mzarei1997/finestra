//
//  OnboardingViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation

@MainActor
@Observable
final class OnboardingViewModel {
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func didTappedOnNext() {
        // if it is last page being tapped
        appState.finishedOnboarding()
    }
}
