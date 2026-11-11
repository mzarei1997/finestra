//
//  SessionEditorView.swift
//  Finestra
//

import SwiftUI

struct SessionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SessionEditorViewModel

    init(
        session: SessionModel,
        onSave: @escaping (SessionModel) -> Void
    ) {
        _viewModel = State(
            initialValue: SessionEditorViewModel(
                session: session,
                onSave: onSave
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Notes", text: $viewModel.note)
                Stepper(
                    "Duration: \(viewModel.duration) min",
                    value: $viewModel.duration,
                    in: 1...120
                )
                DatePicker(
                    "Scheduled for",
                    selection: $viewModel.scheduledFor
                )
                DatePicker(
                    "Start at",
                    selection: $viewModel.startTime,
                    displayedComponents: .hourAndMinute
                )
                Picker("Reminder", selection: $viewModel.reminder) {
                    ForEach(Array(stride(from: 0, through: 60, by: 5)), id: \.self) { minutes in
                        Text(minutes == 0 ? "None" : "\(minutes) min before")
                            .tag(minutes)
                    }
                }
                Picker("Session type", selection: $viewModel.type) {
                    ForEach(SessionType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                            .tag(type)
                    }
                }
                Picker("Priority", selection: $viewModel.priority) {
                    ForEach(SessionPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized)
                            .tag(priority)
                    }
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(SessionStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
            }
            .navigationTitle("Edit session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
