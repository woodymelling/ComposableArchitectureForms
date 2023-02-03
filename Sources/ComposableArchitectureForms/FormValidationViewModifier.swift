//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct FormValidationViewModifier<State: ValidatableState, Action: ValidatableAction>: ViewModifier where State.Field == Action.Field, Action.State == State, State.Field.State == State {

    var store: Store<State, Action>
    var field: State.Field
    var isForTextField: Bool
    var forcedSubmitLabel: SubmitLabel?

    @FocusState private var isFocused: Bool

    var isLastField: Bool {
        return field == Array(Action.Field.allCases).last // Performance bad?
    }

    var submitLabel: SubmitLabel {
        if let forcedSubmitLabel {
            return forcedSubmitLabel
        } else if isLastField {
            return .done
        } else {
            return .next
        }
    }

    struct FieldState {
        var value: any Equatable
        var errorMessage: String?
    }

    func body(content: Content) -> some View {
        WithViewStore(
            store,
            removeDuplicates: { old, new in
                areEqual(
                    first: old[keyPath: field.fieldDataLocation.value],
                    second: new[keyPath: field.fieldDataLocation.value]
                ) && field.fieldDataLocation.error.map { keyPath in
                    old.errors[keyPath: keyPath] == new.errors[keyPath: keyPath]
                } ?? true
            }
        ) { viewStore in
            VStack(alignment: .leading, spacing: isForTextField ? 0 : 5) {
                content
                    .focused($isFocused)
                    .onChange(of: isFocused) { isFocused in
                        if !isFocused {
                            viewStore.send(.validation(.validate(field)))
                        } else {
                            viewStore.send(.focus(.enteredFocus(field)))
                        }
                    }
                    .onChange(of: viewStore.focusedField) {
                        isFocused = $0 == field
                    }
                    .onChange(of: TypeErasedEquatable(value: viewStore.state[keyPath: field.fieldDataLocation.value])) { _ in
                        if let keyPath = field.fieldDataLocation.error, viewStore.state.errors[keyPath: keyPath] != nil {
                            viewStore.send(.validation(.validate(field)))
                        }
                    }
                    .onSubmit {
                        viewStore.send(.focus(.nextButtonTapped(field)))
                    }
                    .submitLabel(submitLabel)

                if let keyPath = field.fieldDataLocation.error, let errorMessage = viewStore.state.errors[keyPath: keyPath] {
                    Forms.errorMessageView(errorMessage)
                }
            }
        }
    }
}

extension View {
    /// Attaches validation for a specific field to a view
    /// - Parameters:
    ///   - store: The FormReducer store that is getting validated against
    ///   - field: The FormReducer.Field that corresponds to the view this is attached to
    ///   - isForTextField: Allows for different view configuration based on whether this is for a textField or not
    ///   - submitLabel: Usually, the last Field will have a .done sumit label, and all others will have .next. Override that with this parameter
    public func validation<State: ValidatableState, Action: ValidatableAction>(
        _ store: Store<State, Action>,
        field: Action.Field,
        isForTextField: Bool = true,
        submitLabel: SubmitLabel? = nil
    ) -> some View where State.Field == Action.Field, Action.State == State, State.Field.State == State {
        self.modifier(
            FormValidationViewModifier(
                store: store,
                field: field,
                isForTextField: isForTextField,
                forcedSubmitLabel: submitLabel
            )
        )
    }
}

private func areEqual(first: Any, second: Any) -> Bool {
    guard
        let equatableOne = first as? any Equatable,
        let equatableTwo = second as? any Equatable
    else { return false }

    return equatableOne.isEqual(equatableTwo)
}

private extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return other.isExactlyEqual(self)
        }
        return self == other
    }

    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}

internal struct TypeErasedEquatable: Equatable {
    let value: Any

    public static func == (lhs: TypeErasedEquatable, rhs: TypeErasedEquatable) -> Bool {
        areEqual(first: lhs.value, second: rhs.value)
    }
}
