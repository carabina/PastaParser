//
//  PPBaseGrammar.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation
import SwiftyXMLParser

/// Base implementation of a grammar.
open class PPGrammar : NSObject {
    
    open override var description: String {
        return ""
    }
    
    /// Package name of this grammar.
    open var packageName: String = ""
    
    /// Root rule of this grammar.
    open lazy var rootRule: PPGrammarRule = {
        let rootRule = PPGrammarRule(grammar: self)
        return rootRule
    }()
    
    // Rules of this grammar.
    open var rules: [PPGrammarRule] {
        get { return rootRule.subrules }
        set { rootRule.subrules = newValue }
    }
    
    open func rules(with ruleType: PPGrammarRuleType) -> [PPGrammarRule] {
        return rootRule.subrules(with: ruleType)
    }
    
    /// Rule map of this grammar.
    open var ruleMap = [String: PPGrammarRule]()
    
    ///
    open var unmatchedRule = PPGrammarRule(id: "UNMATCHED", value: "'.'", componentType: .lexerRule, grammar: nil)
    
    /// Constructs a new grammar with no rules.
    public override init() {
        
    }
    
    /// Constructs a new grammar from a specified file and rule tag.
    /// - parameter file: package from which to load this grammar.
    /// - parameter ruleSetName:
    public init(rootRule: PPGrammarRule, ruleMap: [String : PPGrammarRule]) throws {
        super.init()
        self.rootRule = rootRule
        self.ruleMap = ruleMap
    }
    
    ///
    open func sortRules() {
        rootRule.sort(by: { (a, b) -> Bool in
            return a.order < b.order
        })
    }
    
    ///
    open func rule(for key: String) -> PPGrammarRule? {
        return ruleMap[key]
    }
    
    ///
    open func printRules() {
        for rule in rules {
            print(String(format: "%@ (%ld): %@", rule.id, rule.order, rule))
        }
    }
    
}

