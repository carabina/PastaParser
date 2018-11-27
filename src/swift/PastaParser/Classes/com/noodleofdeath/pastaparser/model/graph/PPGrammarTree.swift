//
//  PPGrammarTree<T>.swift
//  PastaParser
//
//  Created by NoodleOfDeath on 10/31/18.
//  Copyright © 2018 NoodleOfDeath. All rights reserved.
//

import UIKit

/// Specifications for a grammar tree.
public protocol PPGrammarTree: PPTree, PPQuantified where ElementType: PPGrammarTree {
    
}
