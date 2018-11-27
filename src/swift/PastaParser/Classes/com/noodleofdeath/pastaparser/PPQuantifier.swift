//
//  PPQuantifier.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
public struct PPQuantifier {
    
    ///
    public let value: String
    
    ///
    public let optional: Bool
    
    ///
    public let greedy: Bool
    
    ///
    public let lazy: Bool
    
    ///
    public let range: (min: Int, max: Int)?
    
    public var min: Int { return range?.min ?? -1 }
    
    public var max: Int { return range?.max ?? -1 }
    
    public var hasRange: Bool {
        return min > -1 && max > -1;
    }
    
    public func meets(_ matchCount: Int) -> Bool {
        return matchCount >= min && matchCount <= max
    }

    /// 
    public static let noneOrMore = PPQuantifier("*", true, true, false)
    
    /// 
    public static let noneOrMoreLazy = PPQuantifier("*?", true, true, true)
    
    ///
    public static let once = PPQuantifier("", false, false, false)
    
    ///
    public static let onceOrMore = PPQuantifier("+", false, true, false)
    
    ///
    public static let onceOrMoreLazy = PPQuantifier("+?", false, true, true)
    
    ///
    public static let optional = PPQuantifier("?", true, false, false)
    
    ///
    public static let optionalLazy = PPQuantifier("??", true, false, true)
    
    public static let values: [PPQuantifier] = [
        .noneOrMore, .noneOrMoreLazy,
        .once, .onceOrMore, .onceOrMoreLazy,
        .optional, .optionalLazy,
    ]
    
    ///
    public init(_ value: String, _ optional: Bool = false, _ greedy: Bool = false, _ lazy: Bool = false, _ range: (min: Int, max: Int)? = nil) {
        self.value = value
        self.optional = optional
        self.greedy = greedy
        self.lazy = lazy
        self.range = range
    }
    
    public static func from(_ ordinal: Int) -> PPQuantifier {
        return values[ordinal]
    }
    
    public static func from(_ value: String) -> PPQuantifier {
        if value.index(of: "{") == 0,
            let regex = try? NSRegularExpression(pattern: "\\{\\s*(\\d)?(?:\\s*(,)\\s*(\\d)?)?\\s*\\}(\\?)?", options: []) {
            if let match = regex.firstMatch(in: value, options: [], range: value.range) {
                let min = Int(value.substring(with: match.range(at: 1))) ?? 0
                let max = match.range(at: 2).length > 0 ? Int(value.substring(with: match.range(at: 3))) ?? 9 : min
                let lazy = match.range(at: 4).length > 0
                return PPQuantifier(value, min == 0, min < max, lazy, (min: min, max: min >= max ? min : max))
            }
            return .once
        }
        for quantifier in values {
            if value == quantifier.value {
                return quantifier
            }
        }
        return .once
    }
    
    public func equals(_ quantifiers: PPQuantifier...) -> Bool {
        for quantifier in quantifiers {
            if value == quantifier.value {
                return true
            }
        }
        return false
    }
    
}

extension PPQuantifier: CustomStringConvertible {
    
    public var description: String {
        return value
    }
    
}

extension PPQuantifier: CVarArg {

    public var _cVarArgEncoding: [Int] {
        return description._cVarArgEncoding
    }
    
}
