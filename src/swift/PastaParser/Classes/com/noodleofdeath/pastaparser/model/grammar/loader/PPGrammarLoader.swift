//
//  PPGrammarLoader.swift
//  PastaParser
//
//  Created by MORGAN, THOMAS B on 11/26/18.
//

import Foundation
import SwiftyXMLParser

open class PPGrammarLoader : NSObject {
    
    ///
    struct XMLTag {
        public static let grammar = "grammar"
        public static let rules = "rules"
        public static let rule = "rule"
        public static let definition = "definition"
        public static let word = "word"
    }
    
    ///
    struct XMLAttribute {
        public static let extends = "extends"
        public static let id = "id"
        public static let order = "order"
        public static let category = "category"
        public static let options = "options"
    }
    
    struct XMLOption {
        public static let skip = "skip"
        public static let omit = "omit"
        public static let multipass = "multipass"
    }
    
    ///
    struct k {
        
        public static let PackageExtension = "ppgrammar"
        public static let PackageConfigFile = "grammar.xml"
        public static let UnmatchedRuleId = "UNMATCHED"
        public static let UnmatchedRuleExpr = "."
        public static let UnmatchedRuleOrder = Int.max
        
    }
    
    open var searchPaths = [String]()
    
    ///
    /// - parameter searchPaths:
    public init(searchPaths: String...) {
        self.searchPaths = searchPaths
    }
    
    ///
    open class func checkFatal(_ rule: PPGrammarRule) -> Bool {
        if rule.recursive() && rule.recursiveFatal() {
            return true
        }
        return false
    }
    
    /// Returns a specified path ending with exactly one extension occurrence of
    /// `k.PACKAGE_EXTENSION`.
    /// - parameter path: to format.
    /// - returns: path ending with exactly one extension occurrence of
    /// `k.PACKAGE_EXTENSION`.
    open func format(packageName path: String) -> String {
        if path.endIndex == path.range(of: k.PackageExtension)?.upperBound ||
            path.endIndex == path.range(of: k.PackageConfigFile)?.upperBound {
            return path
        }
        return format(configFilePath: String(format: "%@.%@", path, k.PackageExtension))
    }
    
    open func format(configFilePath path: String) -> String {
        if path.endIndex == path.range(of: k.PackageConfigFile)?.upperBound {
            return path
        }
         return String(format: "%@/%@", path, k.PackageConfigFile)
    }
    
    open func load(with id: String) -> PPGrammar? {
        var contents = ""
        for searchPath in searchPaths {
            do {
                let filename = format(packageName: String(format: "%@/%@", searchPath, id))
                contents = try String(contentsOfFile: filename)
                break;
            } catch { continue }
        }
        do {
            return try load(with: XML.parse(contents))
        } catch {
            print(error)
            return nil
        }
    }
    
    ///
    open func load(with accessor: XML.Accessor) throws -> PPGrammar {
        
        let root = accessor[XMLTag.grammar]
        let grammar = PPGrammar()
        
        var rootRule = PPGrammarRule(grammar: grammar)
        var ruleMap = [String : PPGrammarRule]()
        if let unmatchedRule = try parseCompositeRule(k.UnmatchedRuleId, with: k.UnmatchedRuleExpr, grammar: grammar) {
            unmatchedRule.ruleType = .lexerRule
            rootRule.add(unmatchedRule)
            grammar.unmatchedRule = unmatchedRule
        }
        
        if let parentName = root.attributes[XMLAttribute.extends],
            let parentGrammar = load(with: parentName) {
            rootRule = parentGrammar.rootRule
            ruleMap = parentGrammar.ruleMap
        }
        
        let ruleSet = root[XMLTag.rules]
        for node in ruleSet[XMLTag.rule] {
            guard let rule = try parse(node: node, rootRule: rootRule, grammar: grammar) else { continue }
            rule.ruleType = rule.id.firstChar.uppercased() == rule.id.firstChar ? .lexerRule : .parserRule
            if !rule.omit { rootRule.add(rule) }
            ruleMap[rule.id] = rule
        }
        
        grammar.rootRule = rootRule
        grammar.ruleMap = ruleMap
        grammar.sortRules()
        
        return grammar
        
    }
    
    ///
    open func parse(node: XML.Accessor, rootRule: PPGrammarRule? = nil, grammar: PPGrammar) throws -> PPGrammarRule? {
        guard let id = node.attributes[XMLAttribute.id] else { return nil }
        let defNode = node[XMLTag.definition]
        var definition: String
        var words = [String]()
        if defNode.element?.childElements.count != 0 {
            for word in defNode[XMLTag.word] {
                guard let text = word.text else { continue }
                words.append(String(format: "'%@'", text))
            }
            definition = words.joined(separator: " | ")
        } else {
            definition = defNode.text ?? ""
        }
        definition = definition.replacingOccurrences(of: "\\r?\\n|\\s\\s+", with: " ", options: .regularExpression)
        guard let rule = try parseCompositeRule(id, with: definition, composite: true, rootAncestor: rootRule, grammar: grammar) else { return nil }
        if let order = node.attributes[XMLAttribute.order] {
            rule.order ?= Int(order)
        }
        rule.categories ?= node.attributes[XMLAttribute.category]?.components(separatedBy: "[, ]")
        rule.options ?= node.attributes[XMLAttribute.options]?.components(separatedBy: "[, ]")
        return rule
    }
    
    ///
    open func parseAtom(_ id: String, with atom: String, quantifier: String, parent: PPGrammarRule?, grammar: PPGrammar) throws -> PPGrammarRule? {
        
        var atom = atom
        var quantifier = quantifier
        var componentType: PPGrammarRuleComponentType = .atom
        var rule: PPGrammarRule?
        
        if let match = PPPattern.cgExpression.firstMatch(in: atom, options: .anchored) {
            atom = atom.substring(with: match.range(at: 1))
            componentType = .expression
        } else if let match = PPPattern.cgLiteral.firstMatch(in: atom, options: .anchored) {
            atom = atom.substring(with: match.range(at: 1))
            componentType = .literal
        } else if let match = PPPattern.cgGroup.firstMatch(in: atom, options: .anchored) {
            atom = atom.substring(with: match.range(at: 1))
            componentType = .composite
        }
        
        if componentType == .atom {
            componentType = atom.firstChar == atom.firstChar.uppercased() ? .lexerRule : .parserRule
        }
        
        if componentType == .composite {
            
            var slice = ""
            var remainder = ""
            
            var tail: PPGrammarRule?
            var next: PPGrammarRule?
            
            var depth = 0
            var cursor = 0
            var ignore = false
            
            repeat {
                
                let ch = atom.char(at: cursor)
                slice += ch
                
                switch ch {
                    
                case "'", "\"":
                    ignore = !ignore
                    break
                    
                case "(":
                    depth += !ignore ? 1 : 0
                    break
                    
                case ")":
                    depth -= !ignore ? 1 : 0
                    break
                    
                default:
                    break
                    
                }
                
                cursor += 1
                
            } while depth > 0 && cursor < atom.count
            
            if depth > 0 {
                throw PPGrammarError(String(format: "Encountered unmatched parenthesis in rule definition for rule named: %@", id))
            }
            
            if cursor < atom.count {
                
                remainder = atom.substring(cursor)
                if let match = PPPattern.quantifier.firstMatch(in: remainder, options: .anchored) {
                    quantifier = remainder.substring(with: match.range)
                    remainder = remainder.substring(quantifier.count)
                }
                let altIndex = remainder.index(of: "|")
                let grpIndex = remainder.index(of: "(")
                if altIndex > 0 {
                    if grpIndex < 0 || altIndex < grpIndex {
                        let subslice = remainder.substring(altIndex + 1)
                        next = try parseCompositeRule(id, with: subslice, rootAncestor: parent, grammar: grammar)
                        remainder = remainder.substring(0, altIndex)
                    }
                }
                tail = try parseCompositeRule(id, with: remainder, rootAncestor: parent, grammar: grammar)
                
            }
            
            if slice.count > 0 {
                if let match = PPPattern.cgGreedyGroup.firstMatch(in: slice) {
                    slice = slice.substring(with: match.range(at: 1))
                }
            }
            
            rule = try parseCompositeRule(id, with: slice, composite: true, rootAncestor: parent, grammar: grammar)
            if tail != nil {
                rule?.next = tail
            }
            if next != nil {
                parent?.enqueue(next)
            }
            
        } else {
            rule = PPGrammarRule(id: id, value: atom, componentType: componentType, grammar: grammar)
        }
        
        rule?.componentType = componentType
        rule?.quantifier = PPQuantifier.from(quantifier)
        rule?.rootAncestor = parent
        
        return rule
        
    }
    
    ///
    open func parseSimpleRule(_ id: String, with definition: String, parent: PPGrammarRule? = nil, grammar: PPGrammar) throws -> PPGrammarRule? {
        var orig: PPGrammarRule?
        var last: PPGrammarRule?
        var rule: PPGrammarRule?
        for match in PPPattern.cgAtom.matches(in: definition, options: []) {
            let pRange = match.range(at: 1)
            let aRange = match.range(at: 2)
            let qRange = match.range(at: 3)
            let prefix = pRange.location < Int.max ? definition.substring(with: match.range(at: 1)) : ""
            let atom = aRange.location < Int.max ? definition.substring(with: match.range(at: 2)) : ""
            let quantifier = qRange.location < Int.max ? definition.substring(with: match.range(at: 3)) : ""
            rule = try parseAtom(id, with: atom, quantifier: quantifier, parent: parent, grammar: grammar)
            rule?.inverted = prefix == "~"
            last?.next = rule
            last = rule
            if orig == nil {
                orig = rule
            }
        }
        return orig
    }
    
    ///
    open func parseCompositeRule(_ id: String, with definition: String, composite: Bool = false, parent: PPGrammarRule? = nil, rootAncestor: PPGrammarRule? = nil, grammar: PPGrammar) throws -> PPGrammarRule? {
        
        var parent = parent
        var rule: PPGrammarRule?
        
        if composite {
            
            rule = PPGrammarRule(id: id, value: "", componentType: .composite, grammar: grammar)
            parent = rule
            
            /*var slice = ""
             var remainder = ""
             
             var depth = 0
             var cursor = 0
             var ignore = false
             
             let actions: [String: () -> ()] = [
             "'": { ignore = !ignore },
             "\"": { ignore = !ignore },
             "(": { depth += !ignore ? 1: 0 },
             ")": { depth -= !ignore ? 1: 0 },
             "|": {},
             ]
             
             repeat {
             
             let ch = definition.char(at: cursor)
             
             switch ch {
             
             case "'", "\"":
             ignore = !ignore
             break
             
             case "(":
             depth += !ignore ? 1 : 0
             break
             
             case ")":
             depth -= !ignore ? 1 : 0
             break
             
             default:
             break
             
             }
             
             slice += ch
             cursor += 1
             
             } while (depth > 0 && cursor < definition.count)*/
            
            for match in PPPattern.cgAlternative.matches(in: definition, options: []) {
                let alternative = definition.substring(with: match.range).trimmingCharacters(in: .whitespacesAndNewlines)
                if let simpleRule = try parseSimpleRule(id, with: alternative, parent: parent, grammar: grammar) {
                    parent?.add(simpleRule)
                    parent?.consumeQueue()
                }
            }
            
        } else {
            
            rule = try parseSimpleRule(id, with: definition, parent: parent, grammar: grammar)
            rule?.grammar = grammar
            parent?.next = rule
            
        }
        
        return rule
        
    }
    
    
}
