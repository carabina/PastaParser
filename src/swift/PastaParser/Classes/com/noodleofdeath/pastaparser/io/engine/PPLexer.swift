//
//  PPLexer.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
open class PPLexer: PPGrammarEngine {
    
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
    /// - parameter characterStream:
    /// - parameter offset:
    /// - returns:
    public func tokenize(_ characterStream: String, offset: Int = 0) {
        var tokenStream = PPTokenStream(characterStream: characterStream)
        var offset = offset
        let error: Error? = nil
        while offset < characterStream.length {
            var syntaxTree = PPSyntaxTree(options: .lexerTree)
            for rule in grammar.rules(with: .lexerRule) {
                syntaxTree = tokenize(characterStream, rule: rule, offset: offset)
                if syntaxTree.matches {
                    syntaxTree.rule = rule
                    break
                }
            }
            if syntaxTree.matches && !(syntaxTree.rule?.skip ?? false) {
                var token = syntaxTree.generatedToken
                token.rule = syntaxTree.rule
                tokenStream.add(token)
                if syntaxTree.rule == grammar.unmatchedRule {
                    delegate?.engine(self, didSkip: token, in: characterStream)
                } else {
                    delegate?.engine(self, didGenerate: syntaxTree, in: characterStream)
                }
            }
            offset += (syntaxTree.matches ? syntaxTree.length : 1)
        }
        delegate?.engine(didFinish: self, in: characterStream, with: tokenStream, error: error)
    }
    
    ///
    /// - parameter characterStream:
    /// - parameter rule:
    /// - parameter offset:
    /// - parameter syntaxTree:
    /// - returns:
    public func tokenize(_ characterStream: String, rule: PPGrammarRule?, offset: Int, parent syntaxTree: PPSyntaxTree? = nil) -> PPSyntaxTree {
        
        let syntaxTree = syntaxTree ?? .init(options: .lexerTree)
        syntaxTree.rule = rule
        
        guard let rule = rule, rule.exists, offset < characterStream.length else { return syntaxTree }
        let stream = characterStream.substring(offset)
        
        var subtree = PPSyntaxTree(options: .lexerTree)
        var matchCount = 0
        var dx = 0
        
        switch rule.componentType {
            
        case .lexerRule, .lexerFragment:
            
            guard let ruleRef = grammar.rule(for: rule.value) else { return syntaxTree }

            subtree = tokenize(characterStream, rule: ruleRef, offset: offset)
            while rule.inverted != subtree.absoluteMatch {
                if rule.inverted {
                    let token = PPToken(rule: rule, value: stream.firstChar, start: offset + dx, length: 1)
                    subtree = .init(options: .lexerTree)
                    subtree.add(token)
                }
                syntaxTree.add(subtree.tokens)
                matchCount += 1
                dx += subtree.length
                if !rule.quantifier.greedy { break }
                subtree = tokenize(characterStream, rule: ruleRef, offset: offset + dx)
            }
            
            break
            
        case .composite:
            
            if rule.subrules.count > 0 {
                
                for subrule in rule.subrules {
                    subtree = tokenize(characterStream, rule: subrule, offset: offset)
                    if rule.inverted != subtree.absoluteMatch { break }
                }
                
                while rule.inverted != subtree.absoluteMatch {
                    if rule.inverted {
                        let token = PPToken(rule: rule, value: stream.firstChar, start: offset + dx, length: 1)
                        subtree = .init(options: .lexerTree)
                        subtree.add(token)
                    }
                    syntaxTree.add(subtree.tokens)
                    matchCount += 1
                    dx += subtree.length
                    if !rule.quantifier.greedy { break }
                    for subrule in rule.subrules {
                        subtree = tokenize(characterStream, rule: subrule, offset: offset + dx)
                        if rule.inverted != subtree.absoluteMatch { break }
                    }
                }
                
            }
                
            break
            
        default:
            // .literal, .expression
            
            guard let regex = try? NSRegularExpression(pattern: rule.value) else { break }
            
            var range = stream.range
            var match = regex.firstMatch(in: stream, options: .anchored, range: range)
            while rule.inverted != (match != nil) {
                var token: PPToken
                if !rule.inverted, let match = match {
                    token = PPToken(rule: rule, value: stream.substring(with: match.range), start: offset + dx, length: match.range.length)
                } else {
                    token = PPToken(rule: rule, value: stream.firstChar, start: offset + dx, length: 1)
                }
                syntaxTree.add(token)
                matchCount += 1
                dx += token.value.length
                if !rule.quantifier.greedy { break }
                range = NSMakeRange(dx, stream.length - dx)
                match = regex.firstMatch(in: stream, options: .anchored, range: range)
            }
                
            break
            
        }
        
        if (!rule.quantifier.hasRange && matchCount > 0) || rule.quantifier.optional || rule.quantifier.meets(matchCount) {
            if let next = rule.next {
                return tokenize(characterStream, rule: next, offset: offset + dx, parent: syntaxTree)
            }
            syntaxTree.matches = true
        }
        
        return syntaxTree
    }
    
}
