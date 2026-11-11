//
//  FocusView.swift
//  Finestra
//
//  Created by Mohammadreza on 11/11/26.
//

import SwiftUI

struct FocusView: View {
    @State var viewModel: FocusViewModel

    init(viewModel: FocusViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        activeSessionsPanel
                        nearbySessionsPanel
                        todaysSessionsPanel
                        sessionsSection(title: "Upcoming", sessions: viewModel.upcomingSessions)
                        sessionsSection(title: "History", sessions: viewModel.historySessions)
                    }
                    .padding()
                }
            }
            .navigationTitle("Focus")
            .task {
                viewModel.loadSessions()
            }
            .overlay {
                if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Unable to load sessions",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var activeSessionsPanel: some View {
        if !viewModel.activeSessions.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Active sessions")
                    .font(.title2.bold())

                ForEach(viewModel.activeSessions) { session in
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline)
                                    Text(session.timeString(at: context.date))
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack {
                                    Button(session.isPaused ? "Resume" : "Pause") {
                                        viewModel.togglePause(session)
                                    }
                                    .buttonStyle(.bordered)
                                    Button("Stop") {
                                        viewModel.stop(session)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            linearTimer(for: session, at: context.date)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private var nearbySessionsPanel: some View {
        if !viewModel.nearbySessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Nearby sessions")
                    .font(.title2.bold())
                ForEach(viewModel.nearbySessions, id: \.id) { session in
                    sessionRow(session, showsStartButton: true)
                }
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private var todaysSessionsPanel: some View {
        if !viewModel.todaysSessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's sessions")
                    .font(.title2.bold())
                ForEach(viewModel.todaysSessions, id: \.id) { session in
                    sessionRow(session, showsStartButton: false)
                }
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private func sessionsSection(
        title: String,
        sessions: [SessionModel]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            if sessions.isEmpty {
                Text("No sessions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sessions, id: \.id) { session in
                    sessionRow(session, showsStartButton: false)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 24))
    }

    private func sessionRow(
        _ session: SessionModel,
        showsStartButton: Bool
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.rawValue.capitalized)
                    .font(.headline)
                Text(session.startTime, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(session.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(session.status.color)
            }
            Spacer()
            if showsStartButton {
                Button("Start") {
                    viewModel.start(session)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.activeSessions.contains { $0.id == session.id })
            }
        }
    }


    private func linearTimer(for session: ActiveSession, at date: Date) -> some View {
        ZStack(alignment: .leading) {
            GeometryReader { geometry in
                Rectangle()
                    .fill(.red)

                Rectangle()
                    .fill(.indigo)
                    .frame(
                        width: geometry.size.width * session.progress(at: date),
                        height: geometry.size.height
                    )
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
        .padding(.horizontal)
        .background(.background, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
    }
}

#Preview {
    FocusView(viewModel: PreviewFactory.makeFocusViewModel())
}
