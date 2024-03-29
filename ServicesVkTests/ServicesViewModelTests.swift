//
//  ServicesViewModelTests.swift
//  ServicesVkTests
//
//  Created by Elizaveta Osipova on 3/29/24.
//

@testable import ServicesVk
import XCTest

class MockNetworkService: NetworkServiceProtocol {
    var result: Result<Data, NetworkError>?
    
    func load<T>(url: URL?, completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        guard let result = result else {
            completion(.failure(.unknown))
            return
        }
        switch result {
        case .success(let data):
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.requestFailed))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func configureForSuccess(response: String) {
        let data = response.data(using: .utf8)!
        result = .success(data)
    }
    
    func configureForFailure(error: NetworkError) {
        result = .failure(error)
    }
}

final class ServicesViewModelTests: XCTestCase {
    var viewModel: ServicesViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUpWithError() throws {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = ServicesViewModel(networkService: mockNetworkService)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testLoadServicesSuccess() {
        mockNetworkService.configureForSuccess(response: """
          {
              "body": {
                  "services": [
                      {
                          "name": "Test Service",
                          "description": "Test Description",
                          "link": "https://test.com",
                          "icon_url": "https://test.com/icon.png"
                      }
                  ]
              },
              "status": 200
          }
          """)
        
        let expectation = XCTestExpectation(description: "Services should be loaded successfully")
        viewModel.loadServices()
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewModel.services.count, 1)
            XCTAssertEqual(self.viewModel.services.first?.name, "Test Service")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadServicesFailure() {
        mockNetworkService.configureForFailure(error: .badURL)
        
        let expectation = XCTestExpectation(description: "Loading services should fail due to bad URL")
        viewModel.loadServices()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNotNil(self.viewModel.errorAlert, "An error alert should be presented")
            XCTAssertEqual(self.viewModel.errorAlert?.title, "Error", "The error title should be 'Error'")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testResponseDataParsing() throws {
        let jsonData = """
        {
            "body": {
                "services": [
                    {
                        "name": "VKontakte",
                        "description": "The most popular social network and the first super app in Russia",
                        "link": "https://vk.com/",
                        "icon_url": "https://publicstorage.hb.bizmrg.com/sirius/vk.png"
                    }
                ]
            },
            "status": 200
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(ResponseData.self, from: jsonData)
        
        XCTAssertEqual(responseData.status, 200)
        XCTAssertEqual(responseData.body.services.count, 1)
        XCTAssertEqual(responseData.body.services.first?.name, "VKontakte")
        XCTAssertEqual(responseData.body.services.first?.link, "https://vk.com/")
    }
    
    func testOpenServiceLinkSuccess() {
        let serviceLink = "https://test.com"
        viewModel.openServiceLink(serviceLink) { url in
            XCTAssertEqual(url.absoluteString, serviceLink, "The correct URL should be opened")
        }
    }
    
    func testResponseDataDecodingWithInvalidData() {
        let invalidJSONData = """
        {
            "body": {
                "services": "Invalid data"
            }
        }
        """.data(using: .utf8)!
        mockNetworkService.result = .success(invalidJSONData)
        
        let expectation = XCTestExpectation(description: "Decoding error for invalid data should be handled")
        viewModel.loadServices()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.errorAlert, "An error alert for decoding error should be presented")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNetworkErrorHandling() {
        mockNetworkService.result = .failure(.requestFailed)
        
        let expectation = XCTestExpectation(description: "Services loading should fail with a network error")
        
        viewModel.loadServices()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.errorAlert, "An error alert for network failure should be presented")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
