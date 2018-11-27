//
//  PPPattern.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

public func + (lhs: String, rhs: PPPattern) -> String {
    return lhs + rhs.pattern
}

///
public struct PPPattern {
    
    ///
    public static let empty = PPPattern("(?:\\s*;\\s*)")
    
    ///
    public static let literal = PPPattern("(?<!\\\\)'(?:\\\\'|[^'])*'(?:\\s*(?:\\.\\.)(?<!\\\\)'(?:\\\\'|[^'])*')?")
    
    ///
    public static let expression = PPPattern("(?:\\s*\\^?(?:\\[.*?\\]|\\(\\?\\!.*\\)|\\.)\\$?)")
    
    ///
    public static let word = PPPattern("(?:[_\\p{L}]+)")
    
    ///
    public static let group = PPPattern("(?:\\(.*)")
    
    ///
    public static let atom = PPPattern("(?:" + empty + "|" + literal +  "|" + expression + "|" + word + "|" + group + ")")
    
    ///
    public static let quantifier = PPPattern("(?:[\\*\\+\\?]\\??|\\{\\s*\\d\\s*(?:,\\d)?\\}|\\{,\\d\\})")
    
    ///
    public static let cgFragment = PPPattern("(?:fragment\\s+(\\w+))")
    
    ///
    public static let cgDefinition = PPPattern("(.*?)(?:\\s*->\\s*([^']*))?(?:\\s*\\{(.*?)\\})?$")
    
    ///
    public static let cgCommand = PPPattern("(\\w+)\\s*(?:\\((.*?)\\))?")
    
    ///
    public static let cgParserAction = PPPattern("(\\w+)\\s*(?:\\((.*?)\\))?")
    
    ///
    public static let cgAlternative = PPPattern("((?:(~)?" + atom + "\\s*" + quantifier + "?\\s*)+)")
    
    ///
    public static let cgGroup = PPPattern("\\s*(\\(.*)\\s*")
    
    ///
    public static let cgGreedyGroup = PPPattern("\\((.*)\\)")
    
    ///
    public static let cgLiteral = PPPattern("\\s*(?<!\\\\)'((?:\\\\'|[^'])*)'(?:\\s*(?:\\.\\.)(?<!\\\\)'((?:\\\\'|[^'])*)')?\\s*")
    
    ///
    public static let cgExpression = PPPattern("(?:\\s*(" + expression + "))\\s*")
    
    ///
    public static let cgAtom = PPPattern("(~)?\\s*(" + atom + ")\\s*(" + quantifier + "?)")
    
    ///
    fileprivate var pattern = "";
    
    ///
    /// - parameter pattern:
    public init(_ pattern: String) {
        self.pattern = pattern;
    }
    
    ///
    /// - parameter string:
    /// - parameter options:
    /// - parameter range:
    public func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return regex.firstMatch(in: string, options: options, range: range ?? string.range)
    }
    
    ///
    /// - parameter string:
    /// - parameter options:
    /// - parameter range:
    public func matches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: NSRange? = nil) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        return regex.matches(in: string, options: options, range: range ?? string.range)
    }
    
}
