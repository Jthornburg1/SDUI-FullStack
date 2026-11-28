//
//  FormDetailViewModel.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/19/26.
//

import Observation
import Foundation

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
    
    func readValue(_ formFieldId: String) -> Double? {
        guard case .number(let value) = fieldValues[formFieldId] else { return nil }
        
        return value
    }
    
    func setValue(_ formFieldId: String, _ value: Double) {
        if readValue(formFieldId) == value { return }
        
        fieldValues[formFieldId] = .number(value: value)
    }
    
    func readOption(_ formFieldId: String) -> String? {
        guard case .string(let choice) = fieldValues[formFieldId] else { return nil }
        
        return choice
    }
    
    func setOption(_ formFieldId: String, _ option: String) {
        if readOption(formFieldId) == option { return }
        
        fieldValues[formFieldId] = .string(term: option)
    }
    
    func readDate(_ formFieldId: String) -> Date? {
        
        guard case .string(let dateString) = fieldValues[formFieldId] else { return nil }
        let strategy = Date.ParseStrategy(
            format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .twoDigits)",
            locale: Locale(identifier: "en_US_POSIX"), timeZone: .current
        )
        return try? Date(dateString, strategy: strategy)
        
    }
    
    func setDate(_ formFieldId: String, _ selectedDate: Date) {
        if readDate(formFieldId) == selectedDate { return }
        
        let formattedDateString = selectedDate.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
        )
        
        fieldValues[formFieldId] = .string(term: formattedDateString)
    }
    
    func readTime(_ formFieldId: String) -> Date? {
        guard case .string(let timeString) = fieldValues[formFieldId] else { return nil }
        
        let strategy = Date.ParseStrategy(
            format: "\(hour: .twoDigits(clock: .twelveHour, hourCycle: .oneBased))/\(minute: .twoDigits)",
            locale: Locale(identifier: "en_US_POSIX"), timeZone: .current
        )
        
        return try? Date(timeString, strategy: strategy)
    }
    
    func setTime(_ formFieldId: String, _ selectedTime: Date) {
        if readTime(formFieldId) == selectedTime { return }
        
        let formattedTimeString = selectedTime.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
        )
        
        fieldValues[formFieldId] = .string(term: formattedTimeString)
    }
}

