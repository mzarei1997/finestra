//
//  FocusView.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import SwiftUI

struct ScheduleView: View {
    @State private var viewModel: ScheduleViewModel
    init(viewModel: ScheduleViewModel) {
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
                        setupCard
                        startButton
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.isDurationPickerPresented) {
                durationWheelPicker
            }
            .sheet(isPresented: $viewModel.isDatePickerPresented) {
                calendarSelector
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Plan a session or start working right away.")
                .font(.largeTitle.bold())
        }
    }
    
    private var setupCard: some View {
        VStack(spacing: 0) {
            datePicker
            startTimePicker
            reminderPicker
            durationPicker
            sessionTypePicker
            priorityPicker
            noteField
        }
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

    private var startTimePicker: some View {
        DatePicker(
            "Start at",
            selection: $viewModel.startTime,
            displayedComponents: .hourAndMinute
        )
        .padding(.vertical, 8)
    }

    private var reminderPicker: some View {
        HStack {
            Text("Reminder")
            Spacer()
            Picker("Reminder", selection: $viewModel.reminder) {
                ForEach(Array(stride(from: 0, through: 60, by: 5)), id: \.self) { minutes in
                    Text(minutes == 0 ? "None" : "\(minutes) min before")
                        .tag(minutes)
                }
            }
            .tint(.secondary)
        }
        .padding(.vertical, 8)
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
    ScheduleView(viewModel: PreviewFactory.makeScheduleViewModel())
}
