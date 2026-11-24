//
//  FormsService.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/17/26.
//

import Foundation

nonisolated enum FormsNetworkError: Error, Equatable {
    case httpStatus(Int)
    case invalidResponse
    case invalidEndpoint
}

protocol FormsServiceContract {
    func fetchForms() async throws -> [FormSummary]
    func fetchForm(at path: String) async throws -> FormDefinition
}

struct FormsService: FormsServiceContract {
    func fetchForms() async throws -> [FormSummary] {
        let formsContainer: FormsResponse = try await fetch(from: Constants.forms)
        return formsContainer.forms
    }
    
    func fetchForm(at path: String) async throws -> FormDefinition {
        let formDefinition: FormDefinition = try await fetch(from: path)
        return formDefinition
    }
    
    func fetch<T: Decodable>(from path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: URL(string: Constants.domain)) else { throw FormsNetworkError.invalidEndpoint }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            throw FormsNetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpUrlResponse.statusCode) else {
            throw FormsNetworkError.httpStatus(httpUrlResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

