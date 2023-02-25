//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import ComposableArchitecture

public struct FocusReducer<State, Field, Action>: ReducerProtocol
where Action: FormAction, State.Field == Field, Action.Field == Field, State == Action.State, State: FormState, Field: FormField {
    public init() {}

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        guard let focusAction = (/Action.focus).extract(from: action)
        else { return .none }

        switch focusAction {
        case .enteredFocus(let field):
            state.focusedField = field
        case .nextButtonTapped(let field):
            state.focusedField = field.next
        }

        return .none
    }
}

extension CaseIterable where Self: Equatable {
    private var allCases: AllCases { Self.allCases }
    var next: Self? {
        let index = allCases.index(after: allCases.firstIndex(of: self)!)
        guard index != allCases.endIndex else { return nil }
        return allCases[index]
    }
}
