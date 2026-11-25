//
//  FormDetailViewModel.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/19/26.
//

import Observation

@Observable
@MainActor
class FormDetailViewModel {
    @ObservationIgnored let service: FormsServiceContract
    
    let summary: FormSummary
    
    var definition: FormDefinition?
    var fieldValues: [String: FormFieldValue] = [:]
    var isLoading = false
    var errorMessage: String?
    
    init(summary: FormSummary, service: FormsServiceContract? = nil) {
        self.service = service ?? FormsService()
        self.summary = summary
    }
    
    func callFetchForm() async {
        if isLoading || definition != nil { return }
        errorMessage = nil
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            definition = try await service.fetchForm(at: summary.path)
            fillFieldValues()
            
        } catch {
            errorMessage = Constants.loadingErrorMessage
        }
    }
    
    private func fillFieldValues() {
        guard let definition = definition else { return }
        for section in definition.sections {
            for field in section.fields {
                if let defaultValue = field.defaultValue {
                    fieldValues[field.id] = defaultValue
                }
            }
        }
    }
    
    // Functions to pass that allow the fieldValues to be read and written in the UI element views. There'll be a pair of these per UI element type (nearly).
    func readText(_ formFieldId: String) -> String? {
        guard case .string(let text) = fieldValues[formFieldId] else { return nil }
        return text
    }
    
    func writeText(_ formFieldId: String, _ newText: String) {
        
        // Prevent writing to the dictionary twice!
        if readText(formFieldId) == newText { return }
        
        fieldValues[formFieldId] = .string(term: newText)
    }
    
    func readBool(_ formFieldId: String) -> Bool? {
        guard case .toggle(let enabled) = fieldValues[formFieldId] else { return nil }
        
        return enabled
    }
    
    func setBool(_ formFieldId: String, _ enabled: Bool) {
        if readBool(formFieldId) == enabled { return }
        
        fieldValues[formFieldId] = .toggle(state: enabled)
    }
}

