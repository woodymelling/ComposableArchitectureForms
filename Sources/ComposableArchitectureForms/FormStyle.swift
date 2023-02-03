//
//  File.swift
//  
//
//  Created by Woodrow Melling on 11/21/22.
//

import Foundation
import SwiftUI

public struct Forms {
    private(set) public static var errorMessageView: (String) -> AnyView = { errorMessage in
        AnyView(
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        )
    }
    
    private(set) public static var debounceTime: DispatchQueue.SchedulerTimeType.Stride = 1

    static func configure<Content: View>(
        @ViewBuilder errorMessageView: @escaping (String) -> Content,
        debounceTime: DispatchQueue.SchedulerTimeType.Stride = 1
    ) {
        Self.errorMessageView = {
            AnyView(errorMessageView($0))
        }
        
        Self.debounceTime = debounceTime
    }
}
