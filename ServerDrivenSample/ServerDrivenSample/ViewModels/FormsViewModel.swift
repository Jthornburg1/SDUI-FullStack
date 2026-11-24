//
//  FormsViewModel.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/17/26.
//

import Observation

@Observable
@MainActor
class FormsViewModel {
    @ObservationIgnored var formsService: FormsServiceContract
    
    var isLoading = false
    var errorMessage: String?
    var forms: [FormSummary] = []
    
    init(formsService: FormsServiceContract? = nil) {
        self.formsService = formsService ?? FormsService()
    }
    
    func callFetchForms() async {
        if isLoading{ return }
        errorMessage = nil
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            forms = try await formsService.fetchForms()
        } catch {
            errorMessage = Constants.loadingErrorMessage
        }
    }
}

