//
//  OnboardingView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    @State private var selectedPage = 0
    
    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $selectedPage) {
                ForEach(Array(viewModel.sports.enumerated()), id: \.element.id) { index, sport in
                    VStack(spacing: 20) {
                        Image(systemName: sport.icon)
                            .font(.system(size: 72))
                            .foregroundStyle(.tint)
                        Text(sport.name).font(.title.bold())
                        Text(sport.description)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 28)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(selectedPage == viewModel.sports.count - 1 ? "Get started" : "Next") {
                if selectedPage == viewModel.sports.count - 1 {
                    viewModel.didTappedOnNext(isLastPage: true)
                } else {
                    withAnimation { selectedPage += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    OnboardingView(viewModel: PreviewFactory.makeOnboardingViewModel())
}
