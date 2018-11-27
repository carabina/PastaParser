//
//  PPGrammarError.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import UIKit

/// 
open class PPGrammarError: Error {
    
    let message: String
    
    public init(_ message: String) {
        self.message = message
    }
    
}

extension PPGrammarError: CustomStringConvertible {
    
    public var description: String {
        return message
    }
    
}
extension PPGrammarError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return message
    }
    
}
