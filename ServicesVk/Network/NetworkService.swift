//
//  NetworkService.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case requestFailed
    case unknown
}

protocol NetworkServiceProtocol {
    func load<T: Decodable>(url: URL?, completion: @escaping (Result<T, NetworkError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    func load<T>(url: URL?, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        guard let url = url else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data {
                do {
                    let decodedData = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.requestFailed))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
}
