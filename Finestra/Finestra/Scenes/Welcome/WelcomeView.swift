//
//  WelcomeView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct WelcomeView: View {
    @State private var viewModel: WelcomeViewModel

    init(viewModel: WelcomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
            Text(viewModel.model.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text(viewModel.model.subtitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Get started") {
                viewModel.didTapGetStarted()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
    }
}

#Preview {
    WelcomeView(viewModel: PreviewFactory.makeWelcomeViewModel())
}
