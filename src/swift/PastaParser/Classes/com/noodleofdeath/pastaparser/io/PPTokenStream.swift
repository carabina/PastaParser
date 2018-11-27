//
//  PPTokenStream.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/8/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
public struct PPTokenStream : PPGrammarEngineStream {
    
    public var tokens = [PPToken]()
    public let characterStream: String
    
    public var length: Int {
        return tokens.count
    }
    
    public init(characterStream: String) {
        self.characterStream = characterStream
    }
    
    public mutating func add(_ token: PPToken) {
        tokens.append(token)
    }
    
    public func get(token index: Int) -> PPToken {
        return tokens[index]
    }
    
}
