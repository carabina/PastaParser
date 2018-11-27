//
//  PPBaseGrammarRule.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 10/31/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

open class PPGrammarRule: NSObject, PPGrammarTree {
    
    public typealias ElementType = PPGrammarRule
    
    override open var description: String {
        
        var stringValue = ""
        
        switch componentType {
            
        case .literal, .expression:
            stringValue += String(format: "'%@'%@", value, quantifier)
            break
            
        case .composite:
            break
            
        default:
            stringValue += String(format: "%@%@", value, quantifier)
            break
            
        }
        
        if subrules.count > 0 {
            var strings = [String]()
            for subrule in subrules {
                strings.append(subrule.description)
            }
            stringValue += String(format: " (%@)%@", strings.joined(separator: " | "), quantifier)
        }
        
        if let next = next { stringValue += String(format: " %@", next) }
        if inverted { stringValue = String(format: "~%@", stringValue) }
        
        return stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    open var isRoot: Bool {
        return parent == nil
    }
    
    open var isLeaf: Bool {
        return children.count == 0
    }
    
    open var parent: ElementType?
    
    /// Sibling rule that precedes this rule, if one exists.
    open var prev: PPGrammarRule?
    
    /// Sibling rule that follows this rule, if one exists.
    open var next: PPGrammarRule?
    
    open var rootAncestor: ElementType?
    
    /// Indicates if this rule has an inverted prefix "~" or not.
    open var inverted: Bool = false
    
    open var quantifier: PPQuantifier = .once
    
    open var children = [ElementType]()
    
    open var ruleMap = [PPGrammarRuleType : [PPGrammarRule]]()
    
    open var subrules: [ElementType] {
        get { return children }
        set { children = newValue }
    }
    
    open func subrules(with ruleType: PPGrammarRuleType) -> [ElementType] {
        return ruleMap[ruleType] ?? []
    }
    
    /// Length of this rule in terms of node depth.
    open var length: Int {
        var length = 0
        if !quantifier.optional {
            for subrule in subrules {
                if length < subrule.length {
                    length = subrule.length
                }
            }
            length -= 1
        }
        return length + next?.length + !quantifier.optional
    }
    
    /// Id of this grammar rule.
    public let id: String
    
    /// Value of this grammar rule.
    public let value: String
    
    /// Rule type of this grammar rule.
    public var ruleType: PPGrammarRuleType = .unknown
    
    /// Rule type of this grammar rule.
    public var componentType: PPGrammarRuleComponentType
    
    /// Grammar of this grammar rule.
    public var grammar: PPGrammar?
    
    /// Root context of this grammar rule.
    open var rootContext: ElementType?
    
    /// Order of this grammar rule.
    open var order: Int = .max
    
    /// Categories of this grammar rule.
    open var categories = [String]()
    
    /// Options of this grammar rule.
    open var options = [String]()
    
    ///
    open var skip: Bool {
        return options.contains(PPGrammarLoader.XMLOption.skip)
    }
    
    ///
    open var omit: Bool {
        return options.contains(PPGrammarLoader.XMLOption.omit)
    }
    
    ///
    open var multipass: Bool {
        return options.contains(PPGrammarLoader.XMLOption.multipass)
    }
    
    /// Returns `true` if, and only if, `type != PPGrammarRuleType.unknown`;
    /// `false`, otherwise.
    open var exists: Bool {
        return componentType != .unknown
    }
    
    ///
    open var queue = [ElementType]()
    
    /// Constructs a new grammar rule with an initial type and parent grammar.
    /// - parameter type: of this new rule.
    convenience public init(grammar: PPGrammar) {
        self.init(id: "root", grammar: grammar)
    }
    
    /// Constructs a new grammar rule with an initial id, value, type, and
    /// parent grammar.
    /// - parameter id: of this new rule.
    /// - parameter value: of this new rule.
    /// - parameter type: of this new rule.
    /// - parameter grammar: of this new rule.
    required public init(id: String, value: String = "", componentType: PPGrammarRuleComponentType = .unknown, grammar: PPGrammar? = nil) {
        self.id = id
        self.value = value
        self.componentType = componentType
        self.grammar = grammar
    }
    
    public static func == (lhs: PPGrammarRule, rhs: PPGrammarRule) -> Bool {
        return (lhs.id, lhs.value) == (rhs.id, rhs.value)
    }
    
    open func consumeQueue() {
        for rule in queue { add(rule) }
        clearQueue()
    }
    
    open func enqueue(_ rule: ElementType?) {
        guard let rule = rule else { return }
        queue.append(rule)
    }
    
    open func clearQueue() {
        queue.removeAll()
    }
    
    ///
    /// - parameter ref:
    /// - returns:
    open func recursive(_ ref: ElementType? = nil) -> Bool {
        let ref = ref ?? self
        for subrule in subrules {
            if (subrule.componentType.equals(.lexerRule, .lexerFragment, .parserRule) &&
                subrule.value == (ref.id)) || subrule.recursive(ref) {
                return true
            }
        }
        return false
    }
    
    ///
    /// - parameter ref:
    /// - returns:
    open func recursiveFatal(_ ref: ElementType? = nil) -> Bool {
        let ref = ref ?? self
        var fatal = [Bool]()
        for subrule in subrules {
            fatal.append((subrule.componentType.equals(.lexerRule, .lexerFragment, .parserRule) &&
                subrule.value == (ref.id)) || subrule.recursive(ref))
        }
        return !(fatal.count > 0 && fatal.contains(false))
    }
    
    ///
    /// - parameter comparator:
    open func sort(by comparator: (PPGrammarRule, PPGrammarRule) -> Bool) {
        children.sort(by: comparator)
        for child in children {
            var subrules = ruleMap[child.ruleType] ?? []
            subrules.append(child)
            ruleMap[child.ruleType] = subrules
        }
        for (ruleType, rules) in ruleMap {
            ruleMap[ruleType] = rules.sorted(by: comparator)
        }
    }
    
}
