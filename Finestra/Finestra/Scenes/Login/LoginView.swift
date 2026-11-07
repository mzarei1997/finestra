//
//  LoginView.swift
//  Finestra
//
//  Created by Mohammadreza on 10/21/26.
//

import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        // retain its original view model when SwiftUI reevaluates
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Welcome back").font(.largeTitle.bold())
            Text("Sign in to continue your journey.")
                .foregroundStyle(.secondary)
            TextField("Email address", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            Button {
                viewModel.login()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: PreviewFactory.makeLoginViewModel())
}
