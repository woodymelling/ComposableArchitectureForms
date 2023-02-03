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

    struct FormValidityID {}
    
    @Dependency(\.mainQueue) var mainQueue
    
    public func reduce(
        into state: inout State,
        action: Action
    ) -> EffectTask<Action> {
        if let validationAction = (/Action.validation).extract(from: action) {
            switch validationAction {
            case .validate(let field):
                validate(field, state, &state.errors)
                
            case .checkFormValidity:
                var errors = State.ValidationErrors()
                for field in Field.allCases {
                    validate(field, state, &errors)
                }
                state.isValid = errors.isValid
            }

        } else if (/Action.binding).extract(from: action) != nil {
            return .task { .validation(.checkFormValidity) }.debounce(id: FormValidityID.self, for: 1, scheduler: mainQueue)
        }
        
        return .none
    }
}


