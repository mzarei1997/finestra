//
//  HomeView.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    init(viewModel: HomeViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        activeSessionsPanel
                        todaysSessionsPanel
                        setupCard
                        actions
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                viewModel.loadSessions()
            }
            .sheet(isPresented: $viewModel.isDurationPickerPresented) {
                durationWheelPicker
            }
            .sheet(isPresented: $viewModel.isDatePickerPresented) {
                calendarSelector
            }
            .sheet(isPresented: $viewModel.isQuickStartTimerPresented) {
                quickTimerSelector
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Focus")
                .font(.largeTitle.bold())
            Text("Plan a session or start working right away.")
                .foregroundStyle(.secondary)
        }
    }
    
    private var setupCard: some View {
        VStack(spacing: 0) {
            datePicker
            durationPicker
            sessionTypePicker
            priorityPicker
            noteField
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
                                Button("Stop") {
                                    viewModel.stop(session)
                                }
                                .buttonStyle(.bordered)
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
    private var todaysSessionsPanel: some View {
        if !viewModel.todaysSessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Today's sessions")
                    .font(.title2.bold())
                ForEach(viewModel.todaysSessions, id: \.id) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.type.rawValue.capitalized)
                                .font(.headline)
                            Text(session.scheduledFor, format: .dateTime.hour().minute())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Start") {
                            viewModel.start(session)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.activeSessions.contains { $0.id == session.id })
                    }
                }
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 24))
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
    
    private var actions: some View {
        HStack(spacing: 16) {
            startButton
            quickStart
        }
    }
    
    private var quickTimerSelector: some View {
        VStack(spacing: 20) {
            Text("Quick start")
                .font(.headline)
            HStack {
                Text("\(viewModel.quickStartTimer) minutes")
                    .font(.title3.weight(.semibold))
                Stepper("", value: $viewModel.quickStartTimer, step: 1)
                    .labelsHidden()
            }
            Button {
                viewModel.quickStart()
            } label: {
                Text("Start now")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.height(230)])
    }
    
    private var quickStart: some View {
        Button {
            if viewModel.isQuickStartRunning {
                viewModel.stopQuickStart()
            } else {
                viewModel.isQuickStartTimerPresented = true
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(.orange.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: viewModel.isQuickStartRunning ? viewModel.quickStartProgress : 1)
                    .stroke(.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Image(systemName: viewModel.isQuickStartRunning ? "stop.fill" : "bolt.fill")
                    Text(viewModel.isQuickStartRunning ? viewModel.quickStartTimeString : "Quick start")
                        .font(.caption.weight(.semibold))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 100, height: 100)
        .foregroundStyle(.orange)
    }
    
    private var noteField: some View {
        TextField("Notes", text: $viewModel.noteText)
            .padding(.vertical, 8)
    }
    
    private var startButton: some View {
        Button {
            viewModel.saveNewSession()
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Schedule session")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }
    
    private var durationWheelPicker: some View {
        Picker("", selection: $viewModel.duration) {
            ForEach(1...120, id: \.self) { duration in
                Text("\(duration)")
            }
        }
        .pickerStyle(.wheel)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
    }
    
    private var durationPicker: some View {
        settingRow(title: "Duration", value: "\(viewModel.duration) min") {
            viewModel.isDurationPickerPresented = true
        }
    }
    
    private var datePicker: some View {
        settingRow(
            title: "Scheduled for",
            value: viewModel.dates.isEmpty ? "No date selected" : "\(viewModel.dates.count) day(s)"
        ) {
            viewModel.isDatePickerPresented = true
        }
    }
    
    private func settingRow(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
    
    private var calendarSelector: some View {
        MultiDatePicker("", selection: $viewModel.dates, in: Date()...)
            .frame(height: 350)
            .padding()
            .presentationDetents([.height(400)])
    }
    
    private var sessionTypePicker: some View {
        HStack {
            Text("Session type")
            Spacer()
            Picker("Session type", selection: $viewModel.sessionType) {
                ForEach(SessionType.allCases, id: \.self) { type in
                    Label(type.rawValue.capitalized, systemImage: type.imageName)
                        .tag(type)
                }
            }
            .tint(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var priorityPicker: some View {
        HStack {
            Text("Task priority")
            Spacer()
            Circle()
                .fill(viewModel.priority.colorName)
                .frame(width: 10, height: 10)
            Picker("Task priority", selection: $viewModel.priority) {
                ForEach(SessionPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized).tag(priority)
                }
            }
            .tint(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HomeView(viewModel: PreviewFactory.makeHomeViewModel())
}
