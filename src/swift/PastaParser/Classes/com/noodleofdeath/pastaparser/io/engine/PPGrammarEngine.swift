//
//  PPGrammarEngine.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/14/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

public protocol PPGrammarEngineAtom: CustomStringConvertible, CVarArg {
    
}

public protocol PPGrammarEngineStream {
    
}

///
public protocol PPGrammarEngineDelegate: NSObjectProtocol {
    
    ///
    func engine(_ engine: PPGrammarEngine, didSkip atom: PPGrammarEngineAtom, in characterStream: String)
    
    ///
    func engine(_ engine: PPGrammarEngine, didGenerate syntaxTree: PPSyntaxTree, in characterStream: String)
    
    ///
    func engine(didFinish engine: PPGrammarEngine, in characterStream: String, with stream: PPGrammarEngineStream?, error: Error?)
    
}

extension PPGrammarEngineDelegate {
    
    public func engine(didFinish engine: PPGrammarEngine, in characterStream: String) {
        self.engine(didFinish: engine, in: characterStream, with: nil, error: nil)
    }
    
    public func engine(didFinish engine: PPGrammarEngine, in characterStream: String, with stream: PPGrammarEngineStream?) {
        self.engine(didFinish: engine, in: characterStream, with: stream, error: nil)
    }
    
    public func engine(didFinish engine: PPGrammarEngine, in characterStream: String, error: Error?) {
        self.engine(didFinish: engine, in: characterStream, with: nil, error: error)
    }
    
}

public struct PPGrammarEngineOption: OptionSet {
    
    public typealias T = PPGrammarEngineOption
    public typealias RawValue = UInt
    
    public static let verbose = T(rawValue: 1 << 0)
    
    public let rawValue: UInt
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}

public protocol PPGrammarEngine {
    
    ///
    var delegate: PPGrammarEngineDelegate? { get set }
    
}

extension PPGrammarEngine {
    
}
