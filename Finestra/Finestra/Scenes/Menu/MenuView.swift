import SwiftUI

struct MenuView: View {
    @State private var viewModel: MenuViewModel

    init(viewModel: MenuViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        TabView {
            ScheduleView(
                viewModel: ScheduleViewModel(
                    sessionRepository: viewModel.sessionRepository
                )
            )
            .tabItem {
                Label(
                    "Schedule",
                    systemImage: "calendar"
                )
            }
            FocusView(
                viewModel: FocusViewModel(
                    sessionRepository: viewModel.sessionRepository
                )
            )
            .tabItem {
                Label(
                    "Focus",
                    systemImage: "stopwatch"
                )
            }
            AnalyticsView(
                viewModel: AnalyticsViewModel(
                    sessionRepository: viewModel.sessionRepository
                )
            )
            .tabItem {
                Label(
                    "Insights",
                    systemImage: "chart.bar.fill"
                )
            }
        }
    }
}
