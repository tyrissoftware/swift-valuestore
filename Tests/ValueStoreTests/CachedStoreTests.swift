//
//  CachedStoreTests.swift
//
//
//  Created by Rubén García on 5/2/24.
//

import Foundation
import XCTest
import ValueStore

class CachedStoreTests: XCTestCase {
    fileprivate var mock = MovieDto(
        id: UUID(),
        title: "The example movie",
        description: "This movie is just an example of the movie Dto struct"
    )
    
    func test() async throws {
        
        let movieCachedStore = CachedStore(valueStore: Ref<MovieDto>(mock).valueStore) {
            // Here we have the REST API Request but we mocked here
            try await Task.sleep(nanoseconds: 500_000_000)
            return self.mock
        }
        
        
        var movie = try await movieCachedStore.load(())
        print(mock.title)
        print(movie.title)
        XCTAssertEqual(movie.title, "The example movie")
        movie = try await movieCachedStore.load(())
        XCTAssertEqual(movie.title, "The example movie")
        mock.title = "The example movie 3"
        movie = try await movieCachedStore.update(())
        XCTAssertEqual(movie.title, "The example movie 3")
        movie = try await movieCachedStore.load(())
        XCTAssertEqual(movie.title, "The example movie 3")
    }
    
    func testFailingCachedStore() async throws {
        let expectation = XCTestExpectation(description: "Failed load from ValueStore, trying from API")
        let expectation2 = XCTestExpectation(description: "Failed saving to ValueStore")

        let failsCachedStore = CachedStore(valueStore: .error(ValueStoreError.noData)) {
            // Here we have the REST API Request but we mocked here
            try await Task.sleep(nanoseconds: 500_000_000)
            print("This line should be executed on load when the cache fails")
            expectation.fulfill()
            return self.mock
        }
        
        do {
            _ = try await failsCachedStore.load(())
        } catch {
            expectation2.fulfill()
        }
        await fulfillment(of: [expectation, expectation2], timeout:10)
    }
    
    func testFailingValueStoreAndAPIRequest() async throws {
        let failsCachedStore = CachedStore(valueStore: .error(ValueStoreError.noData)) {
            // Aquí estaría la solicitud de la API REST, pero está simulada
            try await Task.sleep(nanoseconds: 500_000_000)
            throw ValueStoreError.noData
        }

        do {
            _ = try await failsCachedStore.load(())
            XCTFail("Expected to throw, but did not throw")
        } catch let error as ValueStoreError {
            // Verificar que el error es el esperado
            if case .noData = error {

            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

}

private struct MovieDto: Codable {
    let id: UUID
    var title: String
    var description: String
}
