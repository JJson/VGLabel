//
//  CFArray+Sequence.swift
//  VGLabel
//
//  Created by Vein on 2017/11/9.
//  Copyright © 2017年 Vein. All rights reserved.
//

import Foundation
import CoreFoundation

extension CFArray: Sequence {
    
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
    
    public struct Iterator: IteratorProtocol {
        
        var array: NSArray
        var idx = 0
        
        init(_ array: CFArray) {
            self.array = array as NSArray
        }
        
        public mutating func next() -> Any? {
            guard idx < array.count else { return nil }
            let value = array[idx]
            idx += 1
            return value
        }
        
    }
    
}
