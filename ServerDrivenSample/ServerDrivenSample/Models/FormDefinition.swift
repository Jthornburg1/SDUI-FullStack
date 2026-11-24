//
//  FormDefinition.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/17/26.
//

struct FormDefinition: Decodable, Identifiable {
    let id: String
    let schemaVersion: Int
    let revision: Int
    let title: String
    let description: String
    let sections: [FormSection]
    let actions: [FormAction]
}

struct FormSection: Decodable, Identifiable {
    let id: String
    let title: String
    let fields: [FormField]
}

struct FormField: Decodable, Identifiable {
    let id: String
    let type: String
    let label: String
    let required: Bool
    let placeholder: String?
    let validation: FormFieldValidation?
    let defaultValue: FormFieldValue?
    let options: [FormFieldOption]?
    let visibleWhen: FormFieldCondition?
}

struct FormFieldValidation: Decodable {
    let minLength: Int?
    let maxLength: Int?
    let min: Double?
    let max: Double?
    let step: Double?
    let integerOnly: Bool?
}

struct FormFieldOption: Decodable {
    let value: String
    let label: String
}

enum FormFieldValue: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolVal = try? container.decode(Bool.self) {
            self = .toggle(state: boolVal)
        } else if let doubleVal = try? container.decode(Double.self) {
            self = .number(value: doubleVal)
        } else if let stringVal = try? container.decode(String.self) {
            self = .string(term: stringVal)
        } else if let multiString = try? container.decode([String].self) {
            self = .multiSelect(options: multiString)
        } else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "No supported type can be decoded from this field value."
                )
            )
        }
    }
    
    case toggle(state: Bool)
    case number(value: Double)
    case multiSelect(options: [String])
    case string(term: String)
}

struct FormFieldCondition: Decodable {
    let fieldId: String
    let equals: FormFieldValue
}

struct FormAction: Decodable, Identifiable {
    let id: String
    let type: String
    let title: String
}

