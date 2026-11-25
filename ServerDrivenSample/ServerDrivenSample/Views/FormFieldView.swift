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
    
    let readBool: (String) -> Bool?
    let setBool: (String, Bool) -> ()
    
    init(
        formField: FormField,
        readText: @escaping (String) -> String?,
        writeText: @escaping (String, String) -> (),
        readBool: @escaping (String) -> Bool?,
        setBool: @escaping (String, Bool) -> ()
    ) {
        self.formField = formField
        self.readText = readText
        self.writeText = writeText
        self.readBool = readBool
        self.setBool = setBool
    }
    
    var body: some View {
        switch formField.type {
        case "text":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            TextField(formField.label, text: text)
                .padding(.horizontal)
        case "toggle":
            let enabled = Binding<Bool>(
                get: { readBool(formField.id) ?? false },
                set: { setBool(formField.id, $0) }
            )
            
            Toggle(isOn: enabled) {
                Text(formField.label)
            }
            .padding(.horizontal)
        default: Text("No Element Supported")
        }
    }
}

//{
//  "id": "followUp",
//  "type": "toggle",
//  "label": "May we contact you?",
//  "required": false,
//  "defaultValue": false
//},
