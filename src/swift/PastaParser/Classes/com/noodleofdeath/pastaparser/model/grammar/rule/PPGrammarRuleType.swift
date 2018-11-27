//
//  PPGrammarRuleType.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
public enum PPGrammarRuleType {
    
    ///
    case unknown
    
    ///
    case lexerRule
    
    ///
    case parserRule
    
    public func equals(_ types: PPGrammarRuleType...) -> Bool {
        return types.contains(self)
    }
    
}
