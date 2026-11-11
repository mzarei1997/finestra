//
//  HomeModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import Foundation
import SwiftUI

struct FocusModel {
    var id: String?
    var note: String?
    var duration: Int?
    var type: SessionType?
    var date: [Date]?
    var startTime: Date?
    var reminder: Int?
    var priority: SessionPriority?
    
    var formattedDates: [Date] {
        guard let date else { return [] }
        return date.sorted()
    }
    
    var isFormComplete: Bool {
        type != nil &&
        startTime != nil &&
        date != nil &&
        priority != nil &&
        !formattedDates.isEmpty
    }
}

enum SessionStatus: String, CaseIterable {
    case scheduled
    case postponed
    case inProgress
    case cancelled
    case completed
}

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
