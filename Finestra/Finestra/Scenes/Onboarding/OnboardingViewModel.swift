//
//  OnboardingViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private let appState: AppState
    let sports = SportModel.samples
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func didTappedOnNext(isLastPage: Bool) {
        if isLastPage {
            appState.finishedOnboarding()
        }
    }
}
