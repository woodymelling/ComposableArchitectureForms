//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation

public typealias FieldDataLocation<State: ValidatableState> = (value: PartialKeyPath<State>, error: (KeyPath<State.ValidationErrors, String?>)?)

public protocol ValidatableField: CaseIterable, Equatable {
    associatedtype State: ValidatableState

    var fieldDataLocation: FieldDataLocation<State> { get }
}
