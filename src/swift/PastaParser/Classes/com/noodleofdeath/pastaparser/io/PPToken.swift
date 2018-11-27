//
//  PPToken.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
public struct PPToken: PPGrammarEngineAtom {

    public static var zero: PPToken {
        return PPToken(value: "", range: NSMakeRange(0, 0))
    }

    public var rule: PPGrammarRule?

    public let value: String
    
    public let range: NSRange
    
    public init(rule: PPGrammarRule? = nil, value: String, range: NSRange) {
        self.rule = rule
        self.value = value
        self.range = range
    }
    
    public init(rule: PPGrammarRule? = nil, value: String, start: Int, length: Int) {
        self.init(rule: rule, value: value, range: NSMakeRange(start, length))
    }
    
}

extension PPToken : CustomStringConvertible {
    
    public var description: String {
        return value
    }
    
}

extension PPToken : CVarArg {
    
    public var _cVarArgEncoding: [Int] {
        return description._cVarArgEncoding
    }
    
}
