//
//  PPQuantified.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 10/31/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import Foundation

///
public protocol PPQuantified {
    
    /// Quantifier of this quantified object.
    var quantifier: PPQuantifier { get set }
    
}
