//
//  Tree.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 8/26/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

/// Specifications for a tree.
public protocol PPTree: PPNode where ElementType: PPTree {
    
    /// Child nodes of this tree.
    var children: [ElementType] { get set }
    
}

extension PPTree {
    
    /// `true` if this tree has no children; `false`, otherwise.
    public var isLeaf: Bool {
        return children.count == 0
    }
    
    /// Appends a child to the children of this tree.
    /// - parameter child: to append to the children of this tree.
    public func add(_ child: ElementType) {
        child.parent = self as? Self.ElementType.ElementType
        children.append(child)
    }
    
    /// Inserts a child into the children of this tree at a specified index.
    /// - parameter child: to insert into the children of this tree.
    /// - parameter index: at which to insert the child node.
    public func add(_ child: ElementType, at index: Int) {
        child.parent = self as? Self.ElementType.ElementType
        children.insert(child, at: index)
    }
    
    /// Removes a child from the children of this tree at the specified index.
    /// - parameter index: of the child to remove from the children of this
    /// tree.
    public func remove(at index: Int) -> ElementType {
        let e = children.remove(at: index)
        e.parent = nil
        return e
    }
    
}
