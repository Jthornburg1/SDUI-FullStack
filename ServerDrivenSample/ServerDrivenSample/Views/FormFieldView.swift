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
    
    let readOption: (String) -> String?
    let setOption: (String, String) -> ()
    
    let readDate: (String) -> Date?
    let setDate: (String, Date) -> ()
    
    let readTime: (String) -> Date?
    let setTime: (String, Date) -> ()
    
    init(
        formField: FormField,
        readText: @escaping (String) -> String?,
        writeText: @escaping (String, String) -> (),
        readBool: @escaping (String) -> Bool?,
        setBool: @escaping (String, Bool) -> (),
        readValue: @escaping (String) -> Double?,
        setValue: @escaping (String, Double) -> (),
        readOption: @escaping (String) -> String?,
        setOption: @escaping (String, String) -> (),
        readDate: @escaping (String) -> Date?,
        setDate: @escaping (String, Date) -> (),
        readTime: @escaping (String) -> Date?,
        setTime: @escaping (String, Date) -> ()
    ) {
        self.formField = formField
        self.readText = readText
        self.writeText = writeText
        self.readBool = readBool
        self.setBool = setBool
        self.readValue = readValue
        self.setValue = setValue
        self.readOption = readOption
        self.setOption = setOption
        self.readDate = readDate
        self.setDate = setDate
        self.readTime = readTime
        self.setTime = setTime
    }
    
    var body: some View {
        switch formField.type {
        case "text":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            VStack(alignment: .leading) {
                Text("\(formField.label):")
                TextField(formField.placeholder ?? "", text: text)
                    .textFieldStyle(.bordered)
                    .textInputBorderShape(.roundedRectangle)
            }
        case "email":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            VStack(alignment: .leading) {
                Text("\(formField.label):")
                TextField(formField.placeholder ?? "", text: text)
                    .textFieldStyle(.bordered)
                    .textInputBorderShape(.roundedRectangle)
                    .keyboardType(.emailAddress)
            }
        case "phone":
            let text = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            VStack(alignment: .leading) {
                Text("\(formField.label):")
                TextField(formField.placeholder ?? "", text: text)
                    .textFieldStyle(.bordered)
                    .textInputBorderShape(.roundedRectangle)
                    .keyboardType(.phonePad)
            }
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
                Text("\(formField.label):")
                Slider(value: value, in: (formField.validation?.min ?? .zero)...(formField.validation?.max ?? .zero), step: formField.validation?.step ?? .zero) {
                    Text(formField.label)
                } minimumValueLabel: {
                    Text(String(formField.validation?.min ?? .zero))
                } maximumValueLabel: {
                    Text(String(formField.validation?.max ?? .zero))
                }
            }
        case "multilineText":
            let paragraph = Binding<String>(
                get: { readText(formField.id) ?? "" },
                set: { writeText(formField.id, $0) }
            )
            
            VStack(alignment: .leading) {
                Text("\(formField.label):")
                TextEditor(text: paragraph)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(12)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(height: 200)
            }
        case "singleSelect":
            let option = Binding<String>(
                get: { readOption(formField.id) ?? formField.options?.first?.value ?? "" },
                set: { setOption(formField.id, $0) }
            )
            
            VStack(alignment: .trailing) {
                Picker(formField.label, selection: option) {
                    ForEach(formField.options ?? [], id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .pickerStyle(.menu)
            }
        case "date":
            let preferredDate = Binding<Date>(
                get: { readDate(formField.id) ?? Date() },
                set: { setDate(formField.id, $0) }
            )
            
            DatePicker(
                formField.label,
                selection: preferredDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.automatic)
        case "time":
            let preferredTime = Binding<Date>(
                get: { readTime(formField.id) ?? Date() },
                set: { setTime(formField.id, $0) }
            )
            
            DatePicker(
                formField.label,
                selection: preferredTime,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.automatic)
        default: Text("No Element Supported")
        }
    }
}


