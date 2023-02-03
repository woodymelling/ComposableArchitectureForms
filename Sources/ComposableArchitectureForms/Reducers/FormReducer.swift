//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import ComposableArchitecture

// MARK: FormReducer Protocols
public protocol FormReducer<State, Action, Field>: ReducerProtocol
where Action: ValidatableAction<Field>, State: ValidatableState {
    associatedtype Field: CaseIterable, Hashable
    associatedtype FormBody: ReducerProtocol<State, Action>

    static func validate(field: Field, state: State, errors: inout State.ValidationErrors)

    @ReducerBuilder<State, Action>
    var formBody: FormBody { get }
}

public extension FormReducer where Action: ValidatableAction<Field>, State: ValidatableState, State == Action.State, Field == State.Field {
    var body: some ReducerProtocol<State, Action> {
        // Not sure why this is needed, was getting cryptic compile errors if I used @ReducerBuilder on here instead fo this combine
        CombineReducers {
            BindingReducer<State, Action>()
            ValidationReducer<State, Field, Action>(validate: Self.validate)
            FocusReducer<State, Field, Action>()
            formBody
        }
    }
}

public extension FormReducer {
    func validateAll(state: inout State) {
        Field.allCases.forEach {
            Self.validate(field: $0, state: state, errors: &state.errors)
        }
    }

    static func stateIsValid(state: State) -> Bool {
        var errors = State.ValidationErrors()

        for field in Field.allCases {
            Self.validate(field: field, state: state, errors: &errors)
        }

        return errors.isValid
    }
}
