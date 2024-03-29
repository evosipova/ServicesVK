//
//  ServicesViewModel.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import Combine
import SwiftUI

enum LoadingState {
    case idle
    case loading
    case failed(Error)
    case loaded
}

class ServicesViewModel: ObservableObject {
    @Published var services = [Service]()
    @Published var errorAlert: ErrorAlert?
    @Published var loadingState = LoadingState.idle

    private var networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func loadServices() {
        self.loadingState = .loading
        let url = URL(string: "https://publicstorage.hb.bizmrg.com/sirius/result.json")
        networkService.load(url: url) { [weak self] (result: Result<ResponseData, NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseData):
                    self?.services = responseData.body.services
                    self?.loadingState = .loaded
                case .failure(let error):
                    self?.handleLoadError(error)
                    self?.loadingState = .failed(error)
                }
            }
        }
    }

    func openServiceLink(_ link: String, using opener: (URL) -> Void) {
        guard let url = URL(string: link) else {
            self.errorAlert = ErrorAlert(title: "Error", message: "Invalid link")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            opener(url)
        } else if let httpsUrl = URL(string: link.replacingOccurrences(of: "myapp://", with: "https://")) {
            opener(httpsUrl)
        }
    }

    private func handleLoadError(_ error: NetworkError) {
        let errorAlert = ErrorAlert(title: "Error", message: self.errorMessage(for: error))
        DispatchQueue.main.async {
            self.errorAlert = errorAlert
        }
    }

    private func errorMessage(for error: NetworkError) -> String {
        switch error {
        case .badURL: return "Invalid URL"
        case .requestFailed: return "Data request error"
        case .unknown: return "Unknown error"
        }
    }
}
