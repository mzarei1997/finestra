//
//  AnalyticsView.swift
//  Finestra
//

import SwiftUI

struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel
    @State private var editingSession: SessionModel?

    init(viewModel: AnalyticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var todaysSessions: [SessionModel] {
        viewModel.sessions.filter { Calendar.current.isDateInToday($0.scheduledFor) }
    }

    private var upcomingSessions: [SessionModel] {
        viewModel.sessions.filter { !Calendar.current.isDateInToday($0.scheduledFor) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to load sessions",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No sessions yet",
                        systemImage: "calendar",
                        description: Text("Schedule a session from Home to see it here.")
                    )
                } else {
                    List {
                        if !todaysSessions.isEmpty {
                            Section("Today") {
                                ForEach(todaysSessions, id: \.id) { session in
                                    sessionRow(session)
                                        .contentShape(Rectangle())
                                        .onTapGesture { editingSession = session }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                viewModel.delete(session)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }

                        if !upcomingSessions.isEmpty {
                            Section("Upcoming") {
                                ForEach(upcomingSessions, id: \.id) { session in
                                    sessionRow(session)
                                        .contentShape(Rectangle())
                                        .onTapGesture { editingSession = session }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                viewModel.delete(session)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.model.title)
            .task { viewModel.loadSessions() }
            .sheet(item: $editingSession) { session in
                SessionEditorView(session: session) { updatedSession in
                    viewModel.update(updatedSession)
                }
            }
        }
    }

    private func sessionRow(_ session: SessionModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: session.type.imageName)
                .frame(width: 28)
                .foregroundStyle(session.priority.colorName)
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.rawValue.capitalized)
                    .font(.headline)
                Text(session.scheduledFor, format: .dateTime.month().day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !session.note.isEmpty {
                    Text(session.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(session.duration) min")
                .font(.subheadline.weight(.semibold))
        }
    }
}

private struct SessionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let session: SessionModel
    let onSave: (SessionModel) -> Void
    @State private var note: String
    @State private var duration: Int
    @State private var type: SessionType
    @State private var scheduledFor: Date
    @State private var priority: SessionPriority

    init(session: SessionModel, onSave: @escaping (SessionModel) -> Void) {
        self.session = session
        self.onSave = onSave
        _note = State(initialValue: session.note)
        _duration = State(initialValue: session.duration)
        _type = State(initialValue: session.type)
        _scheduledFor = State(initialValue: session.scheduledFor)
        _priority = State(initialValue: session.priority)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Notes", text: $note)
                Stepper("Duration: \(duration) min", value: $duration, in: 1...120)
                DatePicker("Scheduled for", selection: $scheduledFor)
                Picker("Session type", selection: $type) {
                    ForEach(SessionType.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                Picker("Priority", selection: $priority) {
                    ForEach(SessionPriority.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
            }
            .navigationTitle("Edit session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(SessionModel(
                            id: session.id,
                            note: note,
                            duration: duration,
                            type: type,
                            scheduledFor: scheduledFor,
                            priority: priority
                        ))
                        dismiss()
                    }
                }
            }
        }
    }
}
