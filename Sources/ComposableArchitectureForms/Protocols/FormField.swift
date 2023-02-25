//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation

public typealias FieldDataLocation<State: FormState> = (value: PartialKeyPath<State>, error: (KeyPath<State.ValidationErrors, String?>)?)

public protocol FormField: CaseIterable, Equatable {
    associatedtype State: FormState

    var fieldDataLocation: FieldDataLocation<State> { get }
}
