//
//  OnboardingView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    var body: some View {
        Button {
            viewModel.didTappedOnNext()
        } label: {
            Text("Onboaridng")
        }
    }
}

#Preview {
//    OnboardingView()
}
