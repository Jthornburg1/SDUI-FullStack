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
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(definition.sections, id: \.id) { section in
                        Text(section.title)
                            .font(.system(size: 20))
                            .bold()
                        VStack(alignment: .trailing, spacing: 8) {
                            ForEach(section.fields, id: \.id) { field in
                                FormFieldView(
                                    formField: field,
                                    readText: viewModel.readText(_:),
                                    writeText: viewModel.writeText(_:_:),
                                    readBool: viewModel.readBool(_:),
                                    setBool: viewModel.setBool(_:_:),
                                    readValue: viewModel.readValue(_:),
                                    setValue: viewModel.setValue(_:_:),
                                    readOption: viewModel.readOption(_:),
                                    setOption: viewModel.setOption(_:_:),
                                    readDate: viewModel.readDate(_:),
                                    setDate: viewModel.setDate(_:_:),
                                    readTime: viewModel.readTime(_:),
                                    setTime: viewModel.setTime(_:_:)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            await viewModel.callFetchForm()
        }
    }
}

#Preview {
    let vm = FormDetailViewModel(summary: FormSummary(id: "", title: "", description: "", path: ""))
    FormFieldView(formField: FormField(id: "", type: "date", label: "Hi there", required: false, placeholder: nil, validation: nil, defaultValue: nil, options: nil, visibleWhen: nil), readText: vm.readText(_:), writeText: vm.writeText(_:_:), readBool: vm.readBool(_:), setBool: vm.setBool(_:_:), readValue: vm.readValue(_:), setValue: vm.setValue(_:_:), readOption: vm.readOption(_:), setOption: vm.setOption(_:_:), readDate: vm.readDate(_:), setDate: vm.setDate(_:_:), readTime: vm.readTime(_:), setTime: vm.setTime(_:_:))
}
