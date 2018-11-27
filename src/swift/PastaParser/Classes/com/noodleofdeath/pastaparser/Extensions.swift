//
//  Extensions.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 11/7/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

// MARK: - Custom Operators

// MARK: - Nil Assignment Operator

///
infix operator ?=

///
/// - parameter lhs:
/// - parameter rhs:
public func ?= <T: Any>(lhs: inout T?, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}

///
/// - parameter lhs:
/// - parameter rhs:
public func ?= <T: Any>(lhs: inout T, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}

// MARK: - Nil Math Operator Extensions

public func + <T: Numeric>(lhs: T, rhs: T?) -> T {
    guard let rhs = rhs else { return lhs }
    return lhs + rhs
}

public func + <T: Numeric>(lhs: T, rhs: Bool?) -> T {
    guard let rhs = rhs else { return lhs }
    return lhs + (rhs ? 1 : 0)
}

///
public struct StringFormattingOption: OptionSet {
    
    public typealias T = StringFormattingOption
    public typealias RawValue = UInt
    
    public static let escaped = T(rawValue: 1 << 0)
    public static let stripOuterBraces = T(rawValue: 1 << 1)
    public static let stripOuterBrackets = T(rawValue: 1 << 2)
    public static let stripOuterParentheses = T(rawValue: 1 << 3)
    public static let truncate = T(rawValue: 1 << 4)
    
    public let rawValue: UInt
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}

// MARK: - String Extensions
extension String {
    
    /// This string casted as an `NSString`.
    public var ns: NSString {
        return (self as NSString)
    }
    
    /// First character of this string as a `String`.
    public var firstChar: String {
        guard let first = first else { return "" }
        return String(first)
    }
    
    /// Last character of this string as a `String`.
    public var lastChar: String {
        guard let last = last else { return "" }
        return String(last)
    }
    
    public var length: Int {
        return ns.length
    }
    
    /// Range of this string.
    public var range: NSRange {
        return NSMakeRange(0, count)
    }
    
}

extension String {
    
    ///
    /// - parameter anIndex:
    /// - returns:
    public func substring(to anIndex: Int) -> String {
        return ns.substring(to: anIndex)
    }
    
    ///
    /// - parameter anIndex:
    /// - returns:
    public func substring(from anIndex: Int) -> String {
        return ns.substring(from: anIndex)
    }
    
    ///
    /// - parameter anIndex:
    /// - returns:
    public func substring(_ anIndex: Int) -> String {
        return substring(from: anIndex)
    }
    
    ///
    /// - parameter aRange:
    /// - returns:
    public func substring(with aRange: NSRange) -> String {
        return ns.substring(with: aRange)
    }
    
    ///
    /// - parameter loc:
    /// - parameter length:
    /// - returns:
    public func substring(_ loc: Int, _ length: Int) -> String {
        return ns.substring(with: NSMakeRange(loc, length))
    }
    
    ///
    /// - parameter anIndex:
    /// - returns:
    public func char(at anIndex: Int) -> String {
        return substring(anIndex, 1)
    }
    
    ///
    /// - parameter substring:
    /// - returns:
    public func range(of substring: String) -> NSRange {
        return ns.range(of: substring)
    }
    
    ///
    /// - parameter substring:
    /// - returns:
    public func index(of substring: String) -> Int {
        return range(of: substring).location
    }
    
    ///
    /// - parameter options:
    /// - returns:
    public func with(options: StringFormattingOption = []) -> String {
        return String(with: self, options: options)
    }
    
}

extension String {
    
    public func replacingOccurrences(of target: String, with replacement: String, options: CompareOptions = [], range: NSRange? = nil) -> String {
        let range = range ?? self.range
        return ns.replacingOccurrences(of: target, with: replacement, options: options, range: range)
    }
    
}

extension String {
    
    public init(with arg: CVarArg, options: StringFormattingOption = []) {
        var text = String(format: "%@", arg)
        switch options {
            
        case _ where options.contains(.stripOuterBraces):
            break
            
        default:
            break
            
        }
        if options.contains(.escaped) {
            text = text.ns.replacingOccurrences(of: "\\r", with: "\\\\r", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\n", with: "\\\\n", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\t", with: "\\\\t", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\s", with: "\\\\s", options: .regularExpression, range: text.range)
        }
        self = text
    }
    
}
