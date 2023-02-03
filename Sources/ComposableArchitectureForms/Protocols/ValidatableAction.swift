//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import ComposableArchitecture

public protocol ValidatableAction<Field>: BindableAction, Equatable {
    associatedtype Field: ValidatableField
    static func validation(_ action: ValidationAction<Field>) -> Self // Enum Case for Validating
    static func focus(_ action: FocusAction<Field>) -> Self // Enum Case for next Button
}

public enum ValidationAction<Field: ValidatableField>: Equatable {
    case validate(_ field: Field)
    case checkFormValidity
}

public enum FocusAction<Field: ValidatableField>: Equatable {
    case nextButtonTapped(_ field: Field)
    case enteredFocus(_ field: Field)
}

