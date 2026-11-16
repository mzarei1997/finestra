//
//  HomeViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {
    private let sessionRepository: SessionRepositoryProtocol
    private(set) var errorMessage: String?
    
    var dates: Set<DateComponents> = []
    var priority: SessionPriority = .medium
    var sessionType: SessionType = .study
    var noteText: String = ""
    var startTime: Date = .now
    var reminder: Int = 10
    var duration: Int = 20
    var isDurationPickerPresented: Bool = false
    var isDatePickerPresented: Bool = false
    var formattedDates: [Date] {
        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: startTime
        )
        return dates
            .compactMap {
                Calendar(identifier: .gregorian).date(
                    from: DateComponents(
                        timeZone: TimeZone(secondsFromGMT: 0),
                        year: $0.year,
                        month: $0.month,
                        day: $0.day,
                        hour: components.hour,
                        minute: components.minute
                        
                    )
                )
            }
            .sorted()
    }
    
    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    func saveNewSession() {
        guard !formattedDates.isEmpty else { return }

        do {
            try formattedDates.forEach { date in
                let session = SessionModel(
                    note: noteText,
                    duration: duration,
                    type: sessionType,
                    scheduledFor: date,
                    reminder: reminder,
                    priority: priority,
                    status: .scheduled
                )
                try sessionRepository.save(session)
            }
            dates.removeAll()
            noteText = ""
            startTime = .now
            reminder = 10
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
