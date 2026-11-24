//
//  FormDetailView.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/19/26.
//

import SwiftUI

struct FormDetailView: View {
    let form: FormSummary
    @State private var viewModel: FormDetailViewModel
    
    init(form: FormSummary) {
        self.form = form
        self.viewModel = FormDetailViewModel(summary: form)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let definition = viewModel.definition {
                VStack {
                    ForEach(definition.sections, id: \.id) { section in
                        Text(section.title)
                            .font(.system(size: 14))
                            .bold()
                        ForEach(section.fields, id: \.id) { field in
                            FormFieldView(
                                formField: field,
                                readText: viewModel.readText(_:),
                                writeText: viewModel.writeText(_:_:)
                            )
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.callFetchForm()
        }
    }
}

#Preview {
    let testSummary = FormSummary(id: "testSummary", title: "Hi there", description: "Where'd you come from?", path: "Doy!!")
    FormDetailView(form: testSummary)
}
