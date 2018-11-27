//
//  PPCompoundGrammarEngine.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/13/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
open class PPCompoundGrammarEngine: PPBaseGrammarEngineDelegate {
    
    ///
    fileprivate let lexerEngine: PPLexerEngineDelegate
    
    ///
    fileprivate let parserEngine: PPParserEngineDelegate
    
    ///
    fileprivate var multipassRanges = [NSRange]()
    
    ///
    public init(lexerEngine: PPLexerEngineDelegate, parserEngine: PPParserEngineDelegate) {
        self.lexerEngine = lexerEngine
        self.parserEngine = parserEngine
        super.init()
        lexerEngine.delegate = self
        parserEngine.delegate = self
    }
    
    ///
    public convenience init(grammar: PPGrammar) {
        self.init(lexerEngine: PPLexerEngineDelegate(grammar: grammar), parserEngine: PPParserEngineDelegate(grammar: grammar))
    }
    
    ///
    /// - parameter characterStream:
    /// - parameter offset:
    /// - parameter verbose:
    public func process(_ characterStream: String, offset: Int = 0, options: PPGrammarEngineOption = []) {
        self.options = options;
        if verbose {
            print()
            print("----- Tokenizing Character Stream -----")
            print()
        }
        lexerEngine.tokenize(characterStream, offset: offset, options: options)
    }
    
    open override func engine(_ engine: PPGrammarEngine, didGenerate syntaxTree: PPSyntaxTree, in characterStream: String) {
        if verbose {
            print(syntaxTree)
        }
        if syntaxTree.rule?.multipass == true && syntaxTree.maxRange < characterStream.length {
            multipassRanges.append(syntaxTree.innerRange)
        }
    }
    
    open override func engine(didFinish engine: PPGrammarEngine, in characterStream: String, with stream: PPGrammarEngineStream?, error: Error?) {
        
        switch engine {
            
        case is PPLexer:
            guard let stream = stream as? PPTokenStream else { return }
            if verbose {
                print()
                print("Lexer did finish tokenizing character stream")
                print(String(format: "%ld tokens were found", stream.length))
                print()
                print("----- Parsing Token Stream -----")
                print()
            }
            parserEngine.parse(stream, options: options)
            break
            
        case is PPParser:
            if verbose {
                print()
                print("Parser did finish parsing token stream")
                print()
            }
            if multipassRanges.count > 0 {
                let range = multipassRanges.removeFirst()
                if range.location + range.length < characterStream.length {
                    process(characterStream.substring(with: range), options: options)
                }
            }
            break
            
        default:
            break
            
        }
        
    }
    
}
