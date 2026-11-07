//
//  SplashView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct SplashView: View {
    @State private var viewModel: SplashViewModel

    init(viewModel: SplashViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.accentColor.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.system(size: 58, weight: .bold))
                Text(viewModel.model.title)
                    .font(.largeTitle.bold())
                Text(viewModel.model.subtitle)
                    .font(.subheadline)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel())
}
