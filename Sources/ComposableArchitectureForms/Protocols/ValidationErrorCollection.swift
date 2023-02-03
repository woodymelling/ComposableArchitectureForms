//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation

// MARK: Error Protocols
public protocol ValidationErrorCollection: Equatable {
    init()
}

public extension ValidationErrorCollection {
    var isValid: Bool {
        let mirror = Mirror(reflecting: self)
        var isValid = true
        for child in mirror.children {
            if let value = child.value as? String? {
                if value != nil {
                    isValid = false
                }
            }
        }
        return isValid
    }
}
