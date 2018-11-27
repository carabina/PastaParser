//
//  PPLexerEngineDelegate.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

open class PPLexerEngineDelegate: PPBaseGrammarEngineDelegate {
    
    open var lexer: PPLexer {
        didSet {
            lexer.delegate = self
        }
    }
    
    public init(lexer: PPLexer) {
        self.lexer = lexer
        super.init()
        lexer.delegate = self
    }
    
    public convenience init(grammar: PPGrammar) {
        self.init(lexer: PPLexer(grammar: grammar))
    }
    
    ///
    /// - parameter characterStream:
    /// - parameter offset:
    /// - parameter verbose:
    open func tokenize(_ characterStream: String, offset: Int = 0, options: PPGrammarEngineOption = []) {
        self.options = options;
        lexer.tokenize(characterStream, offset: offset);
    }
    
}
