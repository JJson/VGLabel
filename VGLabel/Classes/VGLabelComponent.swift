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
        if let tag = tagLabel {
            desc += ", tag: \(tag)"
        }
        
        if let att = attributes {
            desc += ", attributes: \(att)"
        }
        
        return desc
    }
}

public class VGLabelExtractedComponent: NSObject {
    internal var textComponents: [VGLabelComponent]?
    internal var plainText: String?
    
    class func labelExtractedComponent(_ textComponents: [VGLabelComponent], plainText: String) -> VGLabelExtractedComponent {
        let extractedComponent = VGLabelExtractedComponent()
        extractedComponent.textComponents = textComponents
        extractedComponent.plainText = plainText
        return extractedComponent
    }
    
    class func extractTextStyle(_ data: String, paragraphReplacement: String) -> VGLabelExtractedComponent {
        var text: NSString? = nil
        var tag: String? = nil
        var styleData = data
        
        var components = [VGLabelComponent]()
        var lastPosition = 0
        let scanner = Scanner(string: data)
        
        while !scanner.isAtEnd {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            
            let delimiter = String(format: "%@>", text!)
            let position = (styleData as NSString).range(of: delimiter).location
            
            if position != NSNotFound {
                if delimiter.range(of: "<p")?.lowerBound.encodedOffset == 0 {
                    let nsRange = NSRange(location: lastPosition, length: position + delimiter.count - lastPosition)
                    styleData = (styleData as NSString).replacingOccurrences(of: delimiter, with: paragraphReplacement, options: .caseInsensitive, range: nsRange)
                } else {
                    let nsRange = NSRange(location: lastPosition, length: position + delimiter.count - lastPosition)
                    styleData = (styleData as NSString).replacingOccurrences(of: delimiter, with: "", options: .caseInsensitive, range: nsRange)
                }
                
                styleData = styleData.replacingOccurrences(of: "&lt;", with: "<")
                styleData = styleData.replacingOccurrences(of: "&gt;", with: ">")
            }
            
            if text?.range(of: "</").location == 0 {
                // end of tag
                tag = text?.substring(from: 2)
                if position != NSNotFound {
                    var foundComponent: VGLabelComponent?
                    var foundIndex = -1
                    for (index, component) in components.reversed().enumerated() {
                        if component.text.count == 0, component.tagLabel == tag {
                            foundComponent = component
                            foundIndex = components.count - 1 - index
                            break
                        }
                    }
                    if let component = foundComponent {
                            let text = (styleData as NSString).substring(with: NSRange(location: component.position, length: position - component.position))
                        if text.count > 0 {
                            component.text = text
                        } else {
                            components.remove(at: foundIndex)
                        }
                        
                    }
                }
            } else {
                // start of tag
                if let textComponents = text?.substring(from: 1).components(separatedBy: " ") {
                    tag = textComponents[0]
                    var attributes = [String: String]()
                    for (index, textComponent) in textComponents.enumerated() {
                        if index == 0 { continue }
                        let pair = textComponent.components(separatedBy: "=")
                        if pair.count > 0 {
                            let key = pair[0].lowercased()
                            
                            if pair.count >= 2 {
                                // Trim " charactere
                                var value = (pair[1...pair.count - 1]).joined(separator: "=")
                                value = (value as NSString).replacingOccurrences(of: "\"", with: "", options: .literal, range: NSRange(location: 0, length: 1))
                                value = (value as NSString).replacingOccurrences(of: "\"", with: "", options: .literal, range: NSRange(location: value.count-1, length: 1))
                                
                                attributes[key] = value
                            } else if pair.count == 1 {
                                attributes[key] = key
                            }
                        }
                    }
                    let component = VGLabelComponent.compomemt("", tag: tag!, attributes: attributes)
                    component.position = position
                    components.append(component)
                }
                lastPosition = position
            }
        }
        return VGLabelExtractedComponent.labelExtractedComponent(components, plainText: styleData)
    }
}
