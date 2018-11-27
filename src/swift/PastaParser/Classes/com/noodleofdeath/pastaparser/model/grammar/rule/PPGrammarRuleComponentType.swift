//
//  PPGrammarRuleComponentType.swift
//  PastaParser
//
//  Created by MORGAN, THOMAS B on 11/26/18.
//

import Foundation

public enum PPGrammarRuleComponentType {
    
    ///
    case unknown
    
    ///
    case atom
    
    ///
    case composite
    
    ///
    case expression
    
    ///
    case literal
    
    ///
    case lexerRule
    
    ///
    case lexerFragment
    
    ///
    case parserRule
    
    public func equals(_ types: PPGrammarRuleComponentType...) -> Bool {
        return types.contains(self)
    }
    
}
