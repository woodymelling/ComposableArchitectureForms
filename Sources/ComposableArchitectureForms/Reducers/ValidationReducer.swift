//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import ComposableArchitecture

public struct ValidationReducer<State, Field, Action>: ReducerProtocol
where Action: ValidatableAction, Field == Action.Field, State == Action.State, State: ValidatableState {
    public init(validate: @escaping (Field,State, inout State.ValidationErrors) -> Void) {
        self.validate = validate
    }

    var validate: (Field, State, inout State.ValidationErrors) -> Void

    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        if let fieldToValidate = (/Action.validate).extract(from: action) {
            validate(fieldToValidate, state, &state.errors)

        } else if (/Action.binding).extract(from: action) != nil {
            var errors = State.ValidationErrors()
            for field in Field.allCases {

                validate(field, state, &errors)
            }
            state.isValid = errors.isValid
        }



        return .none
    }
}


