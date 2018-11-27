//
//  PPParserEngineDelegate.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
open class PPParserEngineDelegate: PPBaseGrammarEngineDelegate {
    
    ///
    open var parser: PPParser {
        didSet {
            parser.delegate = self
        }
    }
    
    ///
    public init(parser: PPParser) {
        self.parser = parser
        super.init()
        parser.delegate = self
    }
    
    ///
    public convenience init(grammar: PPGrammar) {
        self.init(parser: PPParser(grammar: grammar))
    }
    
    ///
    open func parse(_ tokenStream: PPTokenStream, offset: Int = 0, options: PPGrammarEngineOption = []) {
        self.options = options
        parser.parse(tokenStream, offset: offset)
    }
   
    ///
    open func parse(_ tokenStream: PPTokenStream, rule: PPGrammarRule?, offset: Int = 0, parent syntaxTree: PPSyntaxTree? = nil) -> PPSyntaxTree {
        return parser.parse(tokenStream, rule: rule, offset: offset, parent: syntaxTree)
    }
    
}
