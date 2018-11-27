//
//  Tests.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/7/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import XCTest
import PastaParser

class Tests: XCTestCase {
    
    func testExample() {
        guard
            let grammarsDirectory = Bundle(for: type(of: self)).resourcePath?.ns.appendingPathComponent("grammars"),
            let sampleFile = Bundle(for: type(of: self)).path(forResource: "samples/Test", ofType: "swift")
            else { XCTFail(); return }
        let loader = PPGrammarLoader(searchPaths: grammarsDirectory)
        do {
            guard let grammar = loader.load(with: "public.swift-source") else { XCTFail(); return }
            let text = try String(contentsOfFile: sampleFile)
            let engine = PPCompoundGrammarEngine(grammar: grammar)
            engine.process(text, options: .verbose)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
}
