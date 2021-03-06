//
//  PPBaseGrammar.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation
import SwiftyXMLParser
....Name
/// Base implementation of a grammar.
open class PPGrammar : NSObject {
    
    ///
    struct XMLTag {
        public static let grammar = "grammar"
        public static let lexerRules = "lexer-rules"
        public static let parserRules = "parser-rules"
        public static let rule = "rule"
        public static let definition = "definition"
        public static let word = "word"
    }
    
    ///
    struct k {
        
        public static let PackageExtension = "ppgrammar"
        public static let PackageConfigFile = "grammar.xml"
        public static let UnmatchedRuleId = "UNMATCHED"
        public static let UnmatchedRuleExpr = "."
        public static let UnmatchedRuleOrder = Int.max
        
    }
    
    /// Package name of this grammar.
    open var packageName: String = ""
    
    /// Constructs a new grammar with no rules.
    public override init() {
        
    }
    
}

extension PPGrammar: PPGrammarRuleGenerator {
    
    ///
    open func generateRule(_ id: String, with definition: String = "", type: PPGrammarRuleType = .atom, grammar: PPGrammar? = nil) -> PPGrammarRule {
        return PPGrammarRule(id: id, value: definition, type: type, grammar: self)
    }
    
}
