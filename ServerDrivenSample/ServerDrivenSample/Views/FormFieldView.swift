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
    
    let readValue: (String) -> Double?
    let setValue: (String, Double) -> ()
    
    init(
        formField: FormField,
        readText: @escaping (String) -> String?,
        writeText: @escaping (String, String) -> (),
        readBool: @escaping (String) -> Bool?,
        setBool: @escaping (String, Bool) -> (),
        readValue: @escaping (String) -> Double?,
        setValue: @escaping (String, Double) -> ()
    ) {
        self.formField = formField
        self.readText = readText
        self.writeText = writeText
        self.readBool = readBool
        self.setBool = setBool
        self.readValue = readValue
        self.setValue = setValue
    }
    
    var body: some View {
        switch formField.type {
        case "text":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            TextField(formField.label, text: text)
        case "toggle":
            let enabled = Binding<Bool>(
                get: { readBool(formField.id) ?? false },
                set: { setBool(formField.id, $0) }
            )
            
            Toggle(isOn: enabled) {
                Text(formField.label)
            }
        case "slider":
            let value = Binding<Double>(
                get: { readValue(formField.id) ?? 0.0 },
                set: { setValue(formField.id, $0) }
            )
            
            VStack(alignment: .leading) {
                Text(formField.label)
                Slider(value: value, in: (formField.validation?.min ?? 0.0)...(formField.validation?.max ?? 0.0), step: formField.validation?.step ?? 0.0) {
                    Text(formField.label)
                } minimumValueLabel: {
                    Text(String(formField.validation?.min ?? 0.0))
                } maximumValueLabel: {
                    Text(String(formField.validation?.max ?? 0.0))
                }
            }

        default: Text("No Element Supported")
        }
    }
}
