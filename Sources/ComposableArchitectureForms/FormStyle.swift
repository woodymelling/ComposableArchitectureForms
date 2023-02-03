//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import SwiftUI

public struct FormStyle {
    private(set) public static var errorMessageView: (String) -> AnyView = { errorMessage in
        AnyView(
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        )
    }

    static func configure<Content: View>(
        @ViewBuilder errorMessageView: @escaping (String) -> Content
    ) {
        Self.errorMessageView = {
            AnyView(errorMessageView($0))
        }
    }
}
