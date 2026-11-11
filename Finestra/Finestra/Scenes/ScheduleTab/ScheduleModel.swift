//
//  HomeModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import Foundation
import SwiftUI

enum SessionPriority: String, CaseIterable {
    case high
    case low
    case medium
    
    var colorName: Color {
        switch self {
        case .high:
            Color.red
        case .low:
            Color.green
        case .medium:
            Color.yellow
        }
    }
}

enum SessionType: String, CaseIterable {
    case study
    case work
    case coding
    case exercise
    
    var imageName: String {
        switch self {
        case .study:
            "book.closed"
        case .work:
            "briefcase"
        case .coding:
            "chevron.left.forwardslash.chevron.right"
        case .exercise:
            "brain.head.profile"
        }
    }
    
    var colorTheme: Color {
        switch self {
        case .study:
                .red
        case .work:
                .yellow
        case .coding:
                .green
        case .exercise:
                .indigo
        }
    }
}
