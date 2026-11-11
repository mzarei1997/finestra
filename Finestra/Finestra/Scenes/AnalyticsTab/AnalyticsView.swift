//
//  AnalyticsView.swift
//  Finestra
//

import SwiftUI

struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel

    init(viewModel: AnalyticsViewModel) {
        _viewModel = State(initialValue: viewModel)
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
                        Section("Today") {
                            ForEach(viewModel.orderedTodaySessions, id: \.id) { session in
                                sessionRow(session)
                                    .swipeActions {
                                        rowActions(for: session)
                                    }
                            }
                            .onMove(perform: viewModel.moveTodaySessions)
                        }

                        Section("Upcoming") {
                            ForEach(viewModel.upcomingSessions, id: \.id) { session in
                                sessionRow(session)
                                    .swipeActions {
                                        rowActions(for: session)
                                    }
                            }
                        }

                        Section("History") {
                            ForEach(viewModel.historySessions, id: \.id) { session in
                                sessionRow(session)
                                    .swipeActions {
                                        rowActions(for: session)
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.model.title)
            .task { viewModel.loadSessions() }
            .sheet(item: $viewModel.editingSession) { session in
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
                Text("Starts \(session.startTime, format: .dateTime.hour().minute())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !session.note.isEmpty {
                    Text(session.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(session.duration) min")
                    .font(.subheadline.weight(.semibold))
                Menu {
                    ForEach(SessionStatus.allCases, id: \.self) { status in
                        Button {
                            viewModel.update(session) //MARK: status is missed
                        } label: {
                            Label(status.rawValue, systemImage: status == session.status ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label(session.status.rawValue, systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(session.status.color)
                }
            }
        }
    }

    @ViewBuilder
    private func rowActions(for session: SessionModel) -> some View {
        Button(role: .destructive) {
            viewModel.delete(session)
        } label: {
            Label("Delete", systemImage: "trash")
        }
        Button {
            viewModel.editingSession = session
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }
}

#Preview {
    AnalyticsView(viewModel: PreviewFactory.makeAnalyticsViewModel())
}
