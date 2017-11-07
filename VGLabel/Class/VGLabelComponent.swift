//
//  VGLabelComponent.swift
//  VGLabel
//
//  Created by Vein on 2017/11/7.
//  Copyright © 2017年 Vein. All rights reserved.
//

import Foundation

public class VGLabelComponent: NSObject {
    fileprivate var componentIndex: Int = 0
    fileprivate var text: String = ""
    fileprivate var tagLabel: String?
    fileprivate var attributes: [NSAttributedStringKey: Any]?
    fileprivate var position: Int = 0
    
    class func compomemt(_ text: String, tag: String, attributes: [NSAttributedStringKey: Any]) -> VGLabelComponent {
        return VGLabelComponent(text, tag: tag, attributes: attributes)
    }
    
    init(_ text: String, tag: String, attributes: [NSAttributedStringKey: Any]) {
        self.text = text
        self.attributes = attributes
        tagLabel = tag
    }
    
    class func compomemt(_ tag: String, position: Int, attributes: [NSAttributedStringKey: Any]) -> VGLabelComponent {
        return VGLabelComponent(tag, position: position, attributes: attributes)
    }
    
    init(_ tag: String, position: Int, attributes: [NSAttributedStringKey: Any]) {
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
}
