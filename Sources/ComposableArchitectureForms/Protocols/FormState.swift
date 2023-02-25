//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import ComposableArchitecture

public protocol FormState<Field>: Equatable {
    associatedtype Field: FormField
    associatedtype ValidationErrors: ValidationErrorCollection

    var errors: ValidationErrors { get set }
    var isValid: Bool { get set }
    var focusedField: Field? { get set }
}

//
//struct FormField<Value: Equatable> {
//    @BindingState var value: Value
//    var errorMessage: String?
//}
