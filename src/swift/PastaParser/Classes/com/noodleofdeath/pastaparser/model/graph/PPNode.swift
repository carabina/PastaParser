//
//  PPNode.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

/// Specifications for a node.
public protocol PPNode: NSObjectProtocol {
    
    /// Type used of the ancestor nodes of this node.
    associatedtype ElementType: Any // Should be of type PPNode
    
    /// Root ancestor of this node, if one exists.
    var rootAncestor: ElementType? { get set }
    
    /// Direct parent ancestor of this node, if one exists.
    var parent: ElementType? { get set }
    
}

extension PPNode {
    
    /// Returns `true` if, and only if, this node has no parent node; `false`,
    /// otherwise.
    public var isRoot: Bool {
        return parent == nil
    }
    
}
