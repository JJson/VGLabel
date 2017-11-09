//
//  VGLabelComponent.swift
//  VGLabel
//
//  Created by Vein on 2017/11/7.
//  Copyright © 2017年 Vein. All rights reserved.
//

import Foundation

public class VGLabelComponent: NSObject {
    internal var componentIndex: Int = 0
    internal var text: String = ""
    internal var tagLabel: String?
    internal var attributes: [String: String]?
    internal var position: Int = 0
    
    class func compomemt(_ text: String, tag: String, attributes: [String: String]) -> VGLabelComponent {
        return VGLabelComponent(text, tag: tag, attributes: attributes)
    }
    
    init(_ text: String, tag: String, attributes: [String: String]) {
        self.text = text
        self.attributes = attributes
        tagLabel = tag
    }
    
    class func compomemt(_ tag: String, position: Int, attributes: [String: String]) -> VGLabelComponent {
        return VGLabelComponent(tag, position: position, attributes: attributes)
    }
    
    init(_ tag: String, position: Int, attributes: [String: String]) {
        self.attributes = attributes
        self.position = position
        tagLabel = tag
    }
    
    override public var description : String {
        var desc = "text: \(text), position: \(position)"
        if let tag = tagLabel  {
            desc = desc + ", tag: \(tag)"
        }
        
        if let att = attributes {
            desc = desc + ", attributes: \(att)"
        }
        
        return desc
    }
}

public class VGLabelExtractedComponent: NSObject {
    fileprivate var textComponents: [VGLabelComponent]?
    fileprivate var plainText: String?
    
    class func labelExtractedComponent(_ textComponents: [VGLabelComponent], plainText: String) -> VGLabelExtractedComponent {
        let extractedComponent = VGLabelExtractedComponent()
        extractedComponent.textComponents = textComponents
        extractedComponent.plainText = plainText
        return extractedComponent
    }
    
    class func extractTextStyle(_ data: String, paragraphReplacement: String) {
        var text: NSString? = nil
        var tag: String? = nil
        var styleData = ""
        
        var components = [VGLabelComponent]()
        let lastPosition = 0
        var scanner = Scanner(string: data)
        
        while !scanner.isAtEnd {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            
            let delimiter = String(format: "%@>", text!)
            let position = data.range(of: delimiter)?.lowerBound.encodedOffset
            
            if position != NSNotFound {
//                if delimiter.range(of: "<p")?.lowerBound.encodedOffset == 0 {
//                    styleData = data.replacingOccurrences(of: delimiter, with: paragraphReplacement, options: .caseInsensitive, range: )
//                }
            }
        }
    }
}






















