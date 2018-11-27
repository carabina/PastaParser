# PastaParser

[![CI Status](https://img.shields.io/travis/NoodleOfDeath/PastaParser.svg?style=flat)](https://travis-ci.org/NoodleOfDeath/PastaParser)
[![Version](https://img.shields.io/cocoapods/v/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)
[![License](https://img.shields.io/cocoapods/l/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)
[![Platform](https://img.shields.io/cocoapods/p/PastaParser.svg?style=flat)](https://cocoapods.org/pods/PastaParser)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

```ruby
pod 'PastaParser'
```

## Author

NoodleOfDeath, git@noodleofdeath.com

## License

PastaParser is available under the MIT license. See the LICENSE file for more info.

## Usage

```swift
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
```

