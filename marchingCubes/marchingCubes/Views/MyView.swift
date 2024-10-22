//
//  MyView.swift
//  marchingCubes
//
//  Created by 温嘉宝 on 22.10.2024.
//

import SwiftUI

struct MyView: View {
    @StateObject var viewModel = MyViewModel() // Creating instance of ViewModel
    
    var body: some View {
        List(viewModel.models) { model in
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.headline)
                Text(model.description)
                    .font(.subheadline)
            }
        }
    }
}

struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
    }
}
