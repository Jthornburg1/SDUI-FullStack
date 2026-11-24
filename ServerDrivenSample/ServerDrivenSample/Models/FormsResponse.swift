//
//  FormsResponse.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/17/26.
//

struct FormsResponse: Decodable {
    let schemaVersion: Int
    let forms: [FormSummary]
}

