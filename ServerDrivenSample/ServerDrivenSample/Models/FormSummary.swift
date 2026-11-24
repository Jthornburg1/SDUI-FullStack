//
//  FormSummary.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/17/26.
//

struct FormSummary: Decodable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let path: String
}

