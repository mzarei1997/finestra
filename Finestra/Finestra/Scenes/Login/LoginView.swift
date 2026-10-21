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
        VStack {
            TextField("insert email", text: $viewModel.email)
            Button {
                viewModel.login()
            } label: {
                Text("login")
            }
        }
    }
}

#Preview {
//    LoginView()
}
