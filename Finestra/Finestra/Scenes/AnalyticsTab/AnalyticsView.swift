//
//  AnalyticsView.swift
//  Finestra
//

import SwiftUI
import Charts

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
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This week")
                            .font(.title2.bold())
                        Chart(viewModel.weeklySessionCounts) { day in
                            BarMark(
                                x: .value("Day", day.date, unit: .day),
                                y: .value("Sessions", day.count)
                            )
                            .foregroundStyle(.indigo)
                        }
                        .frame(height: 220)
                        .chartYAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                    }
                    .padding()
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
                            viewModel.updateStatus(status, for: session)
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
