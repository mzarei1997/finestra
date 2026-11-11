//
//  FocusViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/11/26.
//

import Foundation

@MainActor
@Observable
final class FocusViewModel {
    private var sessionRepository: SessionRepositoryProtocol
    
    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }
}
