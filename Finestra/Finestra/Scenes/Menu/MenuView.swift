import SwiftUI

struct MenuView: View {
    @State private var viewModel: MenuViewModel

    init(viewModel: MenuViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        TabView {
            HomeView(viewModel: HomeViewModel(sessionRepository: viewModel.sessionRepository))
                .tabItem { Label("Home", systemImage: "house.fill") }
            AnalyticsView(
                viewModel: AnalyticsViewModel(
                    sessionRepository: viewModel.sessionRepository
                )
            )
            .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
        }
    }
}
