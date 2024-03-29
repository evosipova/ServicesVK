//
//  ServicesView.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import SwiftUI

struct ServicesView: View {
    @ObservedObject var viewModel = ServicesViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.services) { service in
                ServiceRowView(service: service)
                    .onTapGesture {
                        viewModel.openServiceLink(service.link) { url in
                            UIApplication.shared.open(url)
                        }
                    }
            }
            .navigationBarTitle("Сервисы")
            .alert(item: $viewModel.errorAlert) { errorAlert in
                Alert(title: Text(errorAlert.title), message: Text(errorAlert.message), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            viewModel.loadServices()
        }
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView()
    }
}
