//
//  PPParser.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
open class PPParser: PPGrammarEngine {
    
    ///
    public let grammar: PPGrammar
    
    ///
    open weak var delegate: PPGrammarEngineDelegate?
    
    ///
    /// - parameter grammar:
    public init(grammar: PPGrammar) {
        self.grammar = grammar
    }
    
    ///
    /// - parameter tokenStream:
    /// - parameter offset:
    public func parse(_ tokenStream: PPTokenStream, offset: Int = 0) {
        var offset = offset
        while offset < tokenStream.length {
            var syntaxTree = PPSyntaxTree(options: .parserTree)
            for rule in grammar.rules(with: .parserRule) {
                syntaxTree = parse(tokenStream, rule: rule, offset: offset)
                if syntaxTree.matches {
                    syntaxTree.rule = rule
                    break
                }
            }
            if syntaxTree.matches {
                delegate?.engine(self, didGenerate: syntaxTree, in: tokenStream.characterStream)
            } else {
                delegate?.engine(self, didSkip: tokenStream.get(token: offset), in: tokenStream.characterStream)
            }
            offset += (syntaxTree.matches ? syntaxTree.tokenCount : 1)
        }
        delegate?.engine(didFinish: self, in: tokenStream.characterStream)
    }
    
    ///
    /// - parameter tokenStream:
    /// - parameter rule:
    /// - paraneter offset:
    /// - parameter syntaxTree:
    /// - returns:
    public func parse(_ tokenStream: PPTokenStream, rule: PPGrammarRule?, offset: Int, parent syntaxTree: PPSyntaxTree? = nil) -> PPSyntaxTree {
        
        let syntaxTree = syntaxTree ?? .init(options: .parserTree)
        syntaxTree.rule = rule
        
        guard let rule = rule, rule.exists, offset < tokenStream.length else { return syntaxTree }
        
        var subtree = PPSyntaxTree(options: .parserTree)
        var matchCount = 0
        var dx = 0
        
        switch rule.componentType {
            
        case .parserRule:
            
            guard let ruleRef = grammar.rule(for: rule.value) else { return syntaxTree }
            
            subtree = parse(tokenStream, rule: ruleRef, offset: offset)
            while rule.inverted != subtree.absoluteMatch {
                if rule.inverted {
                    subtree = .init(options: .parserTree)
                    subtree.add(tokenStream.get(token: offset + dx))
                }
                syntaxTree.add(subtree.tokens)
                matchCount += 1
                dx += subtree.tokenCount
                if !rule.quantifier.greedy { break }
                subtree = parse(tokenStream, rule: ruleRef, offset: offset + dx)
            }
            
            break
            
        case .composite:
            
            if rule.subrules.count > 0 {
                
                for subrule in rule.subrules {
                    subtree = parse(tokenStream, rule: subrule, offset: offset)
                    if rule.inverted != subtree.absoluteMatch { break }
                }
                
                while rule.inverted != subtree.absoluteMatch {
                    if rule.inverted {
                        subtree = .init(options: .parserTree)
                        subtree.add(tokenStream.get(token: offset + dx))
                    }
                    syntaxTree.add(subtree.tokens)
                    matchCount += 1
                    dx += subtree.tokenCount
                    if !rule.quantifier.greedy { break }
                    for subrule in rule.subrules {
                        subtree = parse(tokenStream, rule: subrule, offset: offset + dx)
                        if rule.inverted != subtree.absoluteMatch { break }
                    }
                }
                
            }
            
            break
            
        case .lexerRule, .lexerFragment:

            var token = tokenStream.get(token: offset)
            while rule.inverted != (rule.value == token.rule?.id) {
                syntaxTree.add(token)
                matchCount += 1
                dx += 1
                if !rule.quantifier.greedy || offset + dx >= tokenStream.length { break }
                token = tokenStream.get(token: offset + dx)
            }
            
            break
            
        default:
            // .literal, .expression
            
            guard let regex = try? NSRegularExpression(pattern: rule.value) else { break }
            
            var token = tokenStream.get(token: offset)
            var match = regex.firstMatch(in: token.value, options: .anchored, range: token.value.range)
            while rule.inverted != (match != nil) {
                syntaxTree.add(token)
                matchCount += 1
                dx += 1
                if !rule.quantifier.greedy || offset + dx >= tokenStream.length { break }
                token = tokenStream.get(token: offset + dx)
                match = regex.firstMatch(in: token.value, options: .anchored, range: token.value.range)
            }
            
            break
            
        }
        
        if (!rule.quantifier.hasRange && matchCount > 0) || rule.quantifier.optional || rule.quantifier.meets(matchCount) {
            if let next = rule.next {
                return parse(tokenStream, rule: next, offset: offset + dx, parent: syntaxTree)
            }
            syntaxTree.matches = true
        }
        
        return syntaxTree
    }
    
}
