//
//  PPBaseGrammarEngineDelegate.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/13/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
open class PPBaseGrammarEngineDelegate: NSObject, PPGrammarEngineDelegate {
    
    open var options: PPGrammarEngineOption = []
    
    open weak var delegate: PPGrammarEngineDelegate?
    
    public var verbose: Bool {
        return options.contains(.verbose)
    }
    
    public func engine(_ engine: PPGrammarEngine, didSkip atom: PPGrammarEngineAtom, in characterStream: String) {
        guard let delegate = delegate else {
            if verbose {
                print(String(format: "Skipped: %@", atom.description.with(options: .escaped)))
            }
            return
        }
        delegate.engine(engine, didSkip: atom, in: characterStream)
    }
    
    public func engine(_ engine: PPGrammarEngine, didGenerate syntaxTree: PPSyntaxTree, in characterStream: String) {
        guard let delegate = delegate else {
            if verbose {
                print(syntaxTree)
            }
            return
        }
        delegate.engine(engine, didGenerate: syntaxTree, in: characterStream)
    }
    
    public func engine(didFinish engine: PPGrammarEngine, in characterStream: String, with stream: PPGrammarEngineStream? = nil, error: Error? = nil) {
        if verbose {
            print()
            print("Done.")
        }
        guard let delegate = delegate else {
            print()
            print("WARNING: No delegate was set for this engine nor is this method  overridden by the extending class.")
            print("It is highly recommneded that a delegate be assigned to this engine and/or extending classes override this method for debugging purposes.")
            return
        }
        delegate.engine(didFinish: engine, in: characterStream, with: stream, error: error)
    }
    
}
