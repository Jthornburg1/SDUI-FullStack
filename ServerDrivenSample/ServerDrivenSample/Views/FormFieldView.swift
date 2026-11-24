//
//  FormFieldView.swift
//  ServerDrivenSample
//
//  Created by jonathan thornburg on 11/20/26.
//

import SwiftUI

struct FormFieldView: View {
    let formField: FormField
    
    let readText: (String) -> String?
    let writeText: (String, String) -> ()
    
    init(
        formField: FormField,
        readText: @escaping (String) -> String?,
        writeText: @escaping (String, String) -> ()
    ) {
        self.formField = formField
        self.readText = readText
        self.writeText = writeText
    }
    
    var body: some View {
        switch formField.type {
        case "text":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            TextField(formField.label, text: text)
        default: Text("No Element Supported")
        }
    }
}
