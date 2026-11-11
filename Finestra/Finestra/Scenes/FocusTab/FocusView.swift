//
//  FocusView.swift
//  Finestra
//
//  Created by Mohammadreza on 11/11/26.
//

import SwiftUI

struct FocusView: View {
    @State var viewModel: FocusViewModel
    
    init(viewModel: FocusViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    FocusView(viewModel: PreviewFactory.makeFocusViewModel())
}
