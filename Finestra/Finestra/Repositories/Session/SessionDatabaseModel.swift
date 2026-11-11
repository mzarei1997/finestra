//
//  SessionDatabaseModel.swift
//  Finestra
//

import SwiftData
import SwiftUI

@Model
final class SessionDatabaseModel {
    @Attribute(.unique) var id: String
    var note: String
    var duration: Int
    var type: String
    var scheduledFor: Date
    var startTime: Date
    var reminder: Int
    var priority: String
    
    init(
        id: String,
        note: String,
        duration: Int,
        type: String,
        scheduledFor: Date,
        startTime: Date,
        reminder: Int,
        priority: String
    ) {
        self.id = id
        self.note = note
        self.duration = duration
        self.type = type
        self.scheduledFor = scheduledFor
        self.reminder = reminder
        self.startTime = startTime
        self.priority = priority
    }
}

struct SessionModel: Identifiable {
    let id: String
    let note: String
    let duration: Int
    let type: SessionType
    let scheduledFor: Date
    let startTime: Date
    let reminder: Int
    let priority: SessionPriority
    
    init(
        id: String = UUID().uuidString,
        note: String,
        duration: Int,
        type: SessionType,
        scheduledFor: Date,
        startTime: Date,
        reminder: Int,
        priority: SessionPriority
    ) {
        self.id = id
        self.note = note
        self.duration = duration
        self.type = type
        self.scheduledFor = scheduledFor
        self.startTime = startTime
        self.reminder = reminder
        self.priority = priority
    }
}
