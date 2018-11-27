//
//  PPSyntaxTree.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import UIKit

/// Data structure representing a grammar rule match tree.
open class PPSyntaxTree: NSObject, PPTree {
    
    public struct InitOption : OptionSet {
        
        public typealias T = InitOption
        public typealias RawValue = UInt
        
        public static let lexerTree = T(rawValue: 1 << 0)
        public static let parserTree = T(rawValue: 1 << 1)
        
        public let rawValue: RawValue
        
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        
    }
    
    public typealias ElementType = PPSyntaxTree
    
    override open var description: String {
        return String(format: "%@: [%@] {%ld} (%ld, %ld)[%ld]", rule?.id ?? "No Match", options.contains(.lexerTree) ? value.with(options: .escaped) : (options.contains(.parserTree) ? tokens.description : value), tokenCount, start, start + length, length)
    }
    
    open var rootAncestor: ElementType?
    
    open var parent: ElementType?
    
    open var children: [ElementType] = []
    
    open var rule: PPGrammarRule?
    
    open var value: String = ""
    
    open var matches = false
    
    open var absoluteMatch: Bool {
        return matches && tokenCount > 0
    }
    
    open var start: Int = -1
    
    open var length: Int {
        return value.count
    }
    
    open var range: NSRange {
        return NSMakeRange(start, length)
    }
    
    open var maxRange: Int {
        return start + length
    }
    
    open var innerRange: NSRange {
        return NSMakeRange(start + 1, length - 2)
    }
    
    open var tokens = [PPToken]()
    
    open var tokenCount: Int {
        return tokens.count
    }
    
    open var options: InitOption = []
    
    open var generatedToken: PPToken {
        return PPToken(value: value, range: range)
    }
    
    public init(options: InitOption = []) {
        self.options = options
    }
    
    open func add(_ token: PPToken) {
        value += token.value
        if tokenCount == 0 { start = token.range.location }
        tokens.append(token)
    }
    
    open func add(_ tokens: [PPToken]) {
        for token in tokens {
            add(token)
        }
    }
    
    open func clear() {
        value = ""
        tokens.removeAll()
    }

}

