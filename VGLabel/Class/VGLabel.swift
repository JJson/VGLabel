//
//  VGLabel.swift
//  VGLabel
//
//  Created by Vein on 2017/11/7.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import CoreText

public enum VGTextAlignment: UInt8 {
    case left
    
    case right
    
    case center
    
    case justified
    
    case natural
}

public enum VGLineBreakMode: UInt8 {
    
    case byWordWrapping
    
    case byCharWrapping
    
    case byClipping
    
    case byTruncatingHead
    
    case byTruncatingTail
    
    case byTruncatingMiddle
}

public protocol VGLabelDelegate: class {
    func vgLabel(_ label: VGLabel, didSelectLink url: URL?)
}

public extension VGLabelDelegate {
    func vgLabel(_ label: VGLabel, didSelectLink url: URL?) {}
}

open class VGLabel: UIView {
    open var text: String {
        willSet {
            self.text = newValue.replacingOccurrences(of: "<br>", with: "\n")
            let component = VGLabelExtractedComponent.extractTextStyle(self.text, paragraphReplacement: self.paragraphReplacement)
            textComponents = component.textComponents
            plainText = component.plainText
            setNeedsDisplay()
        }
    }
    open var plainText: String?
    open var highlightedText: String? {
        willSet {
            self.highlightedText = newValue?.replacingOccurrences(of: "<br>", with: "\n")
            if let highlightedText = self.highlightedText {
                let extractedComponent = VGLabelExtractedComponent.extractTextStyle(highlightedText, paragraphReplacement: self.paragraphReplacement)
                highlightedTextComponents = extractedComponent.textComponents
            }
        }
    }
    open var textColor: UIColor
    open var font: UIFont
    open var linkAttributes: [String: String]?
    open var selectedLinkAttributes: [String: String]?
    open weak var delegate: VGLabelDelegate?
    open var paragraphReplacement: String
    open var textComponents: [VGLabelComponent]?
    open var highlightedTextComponents: [VGLabelComponent]?
    open var textAlignment: VGTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var _optimumSize: CGSize?
    open var optimumSize: CGSize? {
        get {
            render()
            return _optimumSize
        }
        set {
            _optimumSize = newValue
        }
    }
    
    open var lineBreakMode: VGLineBreakMode {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var lineSpacing: CGFloat {
        didSet {
            setNeedsDisplay()
        }
    }
    open var currentSelectedButtonComponentIndex: Int
    open var visibleRange: CFRange?
    open var highlighted: Bool {
        didSet {
            if highlighted != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    public override init(frame: CGRect) {
        font = UIFont.systemFont(ofSize: 15)
        textColor = UIColor.black
        text = ""
        textAlignment = .left
        lineBreakMode = .byWordWrapping
        lineSpacing = 3
        currentSelectedButtonComponentIndex = -1
        paragraphReplacement = "\n"
        highlighted = false
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isMultipleTouchEnabled = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        font = UIFont.systemFont(ofSize: 15)
        textColor = UIColor.black
        text = ""
        textAlignment = .left
        lineBreakMode = .byWordWrapping
        lineSpacing = 3
        currentSelectedButtonComponentIndex = -1
        paragraphReplacement = "\n"
        highlighted = false
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        isMultipleTouchEnabled = true
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        render()
    }
    
    fileprivate func render() {
        if currentSelectedButtonComponentIndex == -1 {
            for view in subviews {
                if view.isKind(of: UIView.self) {
                    view.removeFromSuperview()
                }
            }
        }
        
        if plainText == nil { return }
        
        let currentContext = UIGraphicsGetCurrentContext()
        if let context = currentContext {
            // Drawing code.
            context.textMatrix = .identity
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: frame.height)
            context.concatenate(flipVertical)
        }
        
        // Initialize an attributed string.
        let string: CFString = plainText! as CFString
        
        let attributedString: CFMutableAttributedString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        
        CFAttributedStringReplaceString(attributedString, CFRange(location: 0, length: 0), string)
        
        let styleDictionary = CFDictionaryCreateMutable(nil, 0, [kCFCopyStringDictionaryKeyCallBacks], [kCFTypeDictionaryValueCallBacks])
        
        // Create a color and add it as an attribute to the string.
        // Core Foundation objects returned from annotated APIs are automatically memory managed in Swift—you do not need to invoke the CFRetain, CFRelease, or CFAutorelease functions yourself.
        // https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/WorkingWithCocoaDataTypes.html  Memory Managed Objects
        
        CFDictionaryAddValue(styleDictionary, Unmanaged.passUnretained(kCTForegroundColorAttributeName).toOpaque(), Unmanaged.passUnretained(self.textColor.cgColor).toOpaque())
        
        CFAttributedStringSetAttributes(attributedString, CFRangeMake(0, CFAttributedStringGetLength(attributedString)), styleDictionary, false)
        
        applyParagraphStyle(text: attributedString, attributes: nil, position: 0, length: CFAttributedStringGetLength(attributedString))
        
        let font = CTFontCreateWithName(self.font.fontName as CFString, self.font.pointSize, nil)
        CFAttributedStringSetAttribute(attributedString, CFRange(location: 0, length: CFAttributedStringGetLength(attributedString)), kCTFontAttributeName, font)
        var links = [VGLabelComponent]()
        var components: [VGLabelComponent]? = nil
        
        if highlighted {
            components = highlightedTextComponents
        } else {
            components = self.textComponents
        }
        
        if let labelComponents = components {
            for (index, component) in labelComponents.enumerated() {
                component.componentIndex = index
                
                if component.tagLabel?.caseInsensitiveCompare("i") == .orderedSame {
                    // make font italic
                    applyItalicStyle(attributedString, position: component.position, length: component.text.characters.count)
                } else if component.tagLabel?.caseInsensitiveCompare("b") == .orderedSame {
                    // make font bold
                    applyBoldStyle(attributedString, position: component.position, length: component.text.characters.count)
                } else if component.tagLabel?.caseInsensitiveCompare("bi") == .orderedSame {
                    applyBoldItalicStyle(attributedString, position: component.position, length: component.text.characters.count)
                } else if component.tagLabel?.caseInsensitiveCompare("a") == .orderedSame {
                    if currentSelectedButtonComponentIndex == index {
                        if let selectedLink = selectedLinkAttributes {
                            applyFontAttributes(selectedLink, text: attributedString, position: component.position, length: component.text.characters.count)
                        } else {
                            applyBoldStyle(attributedString, position: component.position, length: component.text.characters.count)
                            applyColor("#FF0000", text: attributedString, position: component.position, length: component.text.characters.count)
                        }
                    } else {
                        if let linkAttribute = linkAttributes {
                            applyFontAttributes(linkAttribute, text: attributedString, position:component.position, length: component.text.characters.count)
                        } else {
                            applySingleUnderlineText(attributedString, position: component.position, length: component.text.characters.count)
                        }
                    }
                    
                    if let attributes = component.attributes {
                        if let hrefValue = attributes["href"]?.replacingOccurrences(of: "'", with: "") {
                            component.attributes!["href"] = hrefValue
                        }
                    }
                    links.append(component)
                } else if component.tagLabel?.caseInsensitiveCompare("u") == .orderedSame ||
                    component.tagLabel?.caseInsensitiveCompare("uu") == .orderedSame {
                    // Underline
                    if component.tagLabel?.caseInsensitiveCompare("u") == .orderedSame {
                        applySingleUnderlineText(attributedString, position: component.position, length: component.text.characters.count)
                    } else {
                        applyDoubleUnderlineText(attributedString, position: component.position, length: component.text.characters.count)
                    }
                    
                    if let color = component.attributes?["color"] {
                        applyUnderlineColor(attributedString, attributeValue: color, position: component.position, length: component.text.characters.count)
                    }
                } else if component.tagLabel?.caseInsensitiveCompare("font") == .orderedSame {
                    applyFontAttributes(component.attributes, text: attributedString, position: component.position, length: component.text.characters.count)
                } else if component.tagLabel?.caseInsensitiveCompare("p") == .orderedSame {
                    applyParagraphStyle(text: attributedString, attributes: component.attributes, position: component.position, length: component.text.characters.count)
                } else if component.tagLabel?.caseInsensitiveCompare("center") == .orderedSame {
                    applyCenterStyle(text: attributedString, position: component.position, length: component.text.characters.count)
                }
            }
            
            // Create the framesetter with the attributed string.
            let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(attributedString)
            
            // Initialize a rectangular path.
            let path = CGMutablePath()
            let bounds = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
            path.addRect(bounds)
            
            // Create the frame and draw it into the graphics context
            // CTFrameRef
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
            
            var range = CFRange()
            let constraint = CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            optimumSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: (plainText?.characters.count)!), nil, constraint, &range)
            
            if currentSelectedButtonComponentIndex == -1 {
                // only check for linkable items the first time, not when it's being redrawn on button pressed
                
                for linkableComponent in links {
                    var height: CGFloat = 0.0
                    let frameLines = CTFrameGetLines(frame)
                    for (index, value) in frameLines.enumerated() {
                        let line = value as! CTLine
                        let lineRange = CTLineGetStringRange(line)
                        
                        var ascent: CGFloat = 0
                        var descent: CGFloat = 0
                        var leading: CGFloat = 0
                        
                        CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
                        var origin = CGPoint()
                        CTFrameGetLineOrigins(frame, CFRange(location: index, length: 1), &origin)
                        
                        if (linkableComponent.position < lineRange.location &&
                            linkableComponent.position + linkableComponent.text.characters.count > lineRange.location) ||
                            (linkableComponent.position >= lineRange.location && linkableComponent.position < lineRange.location + lineRange.length) {
                            var secondaryOffset: CGFloat = 0.0
                            let line: CTLine = unsafeBitCast(CFArrayGetValueAtIndex(frameLines, index), to: CTLine.self)
                            let primaryOffset = CTLineGetOffsetForStringIndex(line, linkableComponent.position, &secondaryOffset)
                            let primaryOffset2 = CTLineGetOffsetForStringIndex(line, linkableComponent.position + linkableComponent.text.characters.count, nil)
                            
                            let buttonWidth = primaryOffset2 - primaryOffset
                            let button = VGLabelButton(frame: CGRect(x: primaryOffset + origin.x, y: height, width: buttonWidth, height: ascent + descent))
                            button.backgroundColor = .clear
                            button.componentIndex = linkableComponent.componentIndex
                            
                            if let href = linkableComponent.attributes?["href"] {
                                button.url = URL(string: href)
                            }
                            
                            button.addTarget(self, action: #selector(onButtonTouchDown(_:)), for: .touchDown)
                            button.addTarget(self, action: #selector(onButtonTouchUpOutside(_:)), for: .touchUpOutside)
                            button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
                            addSubview(button)
                        }
                        
                        origin.y = self.frame.height - origin.y
                        height = origin.y + descent + lineSpacing
                    }
                }
            }
            visibleRange = CTFrameGetVisibleStringRange(frame)
            if let context = currentContext {
                CTFrameDraw(frame, context)
            }
        }
    }
    
    // MARK: styling
    public func applyParagraphStyle(text: CFMutableAttributedString, attributes: [String: String]?, position: Int, length: Int) {
        
        let styleDictionary = CFDictionaryCreateMutable(nil, 0, [kCFCopyStringDictionaryKeyCallBacks], [kCFTypeDictionaryValueCallBacks])
        
        var direction: CTWritingDirection = .leftToRight
        
        var firstLineIndent: CGFloat = 0.0
        var headIndent: CGFloat = 0.0
        var tailIndent: CGFloat = 0.0
        var lineHeightMultiple: CGFloat = 1.0
        var maximumLineHeight: CGFloat = 0.0
        var minimumLineHeight: CGFloat = 0.0
        var paragraphSpacing: CGFloat = 0.0
        var paragraphSpacingBefore: CGFloat = 0.0
        var textAlignment: CTTextAlignment = CTTextAlignment(rawValue: self.textAlignment.rawValue)!
        var lineBreakMode: CTLineBreakMode = CTLineBreakMode(rawValue: self.lineBreakMode.rawValue)!
        var lineSpacing: CGFloat = self.lineSpacing
        
        if let attr = attributes {
            let keys = Array(attr.keys)
            for key in keys {
                let value = attr[key]!
                if key.caseInsensitiveCompare("align") == .orderedSame {
                    if value.caseInsensitiveCompare("left") == .orderedSame {
                        textAlignment = .left
                    } else if value.caseInsensitiveCompare("right") == .orderedSame {
                        textAlignment = .right
                    } else if value.caseInsensitiveCompare("justify") == .orderedSame {
                        textAlignment = .justified
                    } else if value.caseInsensitiveCompare("center") == .orderedSame {
                        textAlignment = .center
                    }
                } else if key.caseInsensitiveCompare("indent") == .orderedSame {
                    firstLineIndent = value.cgFloat()!
                } else if key.caseInsensitiveCompare("linebreakmode") == .orderedSame {
                    if value.caseInsensitiveCompare("wordwrap") == .orderedSame {
                        lineBreakMode = .byWordWrapping
                    } else if value.caseInsensitiveCompare("charwrap") == .orderedSame {
                        lineBreakMode = .byCharWrapping
                    } else if value.caseInsensitiveCompare("clipping") == .orderedSame {
                        lineBreakMode = .byClipping
                    } else if value.caseInsensitiveCompare("truncatinghead") == .orderedSame {
                        lineBreakMode = .byTruncatingHead
                    } else if value.caseInsensitiveCompare("truncatingtail") == .orderedSame {
                        lineBreakMode = .byTruncatingTail
                    } else if value.caseInsensitiveCompare("truncatingmiddle") == .orderedSame {
                        lineBreakMode = .byTruncatingMiddle
                    }
                }
            }
        }
        let styleSettings: [CTParagraphStyleSetting] = [
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &textAlignment),
            CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &lineBreakMode),
            CTParagraphStyleSetting(spec: .baseWritingDirection, valueSize: MemoryLayout<CTWritingDirection>.size, value: &direction),
            CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .firstLineHeadIndent, valueSize: MemoryLayout<CGFloat>.size, value: &firstLineIndent),
            CTParagraphStyleSetting(spec: .headIndent, valueSize: MemoryLayout<CGFloat>.size, value: &headIndent),
            CTParagraphStyleSetting(spec: .tailIndent, valueSize: MemoryLayout<CGFloat>.size, value: &tailIndent),
            CTParagraphStyleSetting(spec: .lineHeightMultiple, valueSize: MemoryLayout<CGFloat>.size, value: &lineHeightMultiple),
            CTParagraphStyleSetting(spec: .maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &maximumLineHeight),
            CTParagraphStyleSetting(spec: .minimumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &minimumLineHeight),
            CTParagraphStyleSetting(spec: .paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacing),
            CTParagraphStyleSetting(spec: .paragraphSpacingBefore, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacingBefore)
        ]
        
        let paragraphStyle = CTParagraphStyleCreate(styleSettings, styleSettings.count)
        
        CFDictionaryAddValue(styleDictionary, Unmanaged.passUnretained(kCTParagraphStyleAttributeName).toOpaque(), Unmanaged.passUnretained(paragraphStyle).toOpaque())
        CFAttributedStringSetAttributes(text, CFRange(location: position, length: length), styleDictionary, false)
    }
    
    func applyCenterStyle(text: CFMutableAttributedString, position: Int, length: Int) {
        let styleDictionary = CFDictionaryCreateMutable(nil, 0, [kCFCopyStringDictionaryKeyCallBacks], [kCFTypeDictionaryValueCallBacks])
        
        var direction: CTWritingDirection = .leftToRight
        
        var firstLineIndent: CGFloat = 0.0
        var headIndent: CGFloat = 0.0
        var tailIndent: CGFloat = 0.0
        var lineHeightMultiple: CGFloat = 1.0
        var maximumLineHeight: CGFloat = 0.0
        var minimumLineHeight: CGFloat = 0.0
        var paragraphSpacing: CGFloat = 0.0
        var paragraphSpacingBefore: CGFloat = 0.0
        var textAlignment: CTTextAlignment = .center
        var lineBreakMode: CTLineBreakMode = CTLineBreakMode(rawValue: self.lineBreakMode.rawValue)!
        var lineSpacing: CGFloat = self.lineSpacing
        
        let styleSettings: [CTParagraphStyleSetting] = [
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &textAlignment),
            CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout<CTLineBreakMode>.size, value: &lineBreakMode),
            CTParagraphStyleSetting(spec: .baseWritingDirection, valueSize: MemoryLayout<CTWritingDirection>.size, value: &direction),
            CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .firstLineHeadIndent, valueSize: MemoryLayout<CGFloat>.size, value: &firstLineIndent),
            CTParagraphStyleSetting(spec: .headIndent, valueSize: MemoryLayout<CGFloat>.size, value: &headIndent),
            CTParagraphStyleSetting(spec: .tailIndent, valueSize: MemoryLayout<CGFloat>.size, value: &tailIndent),
            CTParagraphStyleSetting(spec: .lineHeightMultiple, valueSize: MemoryLayout<CGFloat>.size, value: &lineHeightMultiple),
            CTParagraphStyleSetting(spec: .maximumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &maximumLineHeight),
            CTParagraphStyleSetting(spec: .minimumLineHeight, valueSize: MemoryLayout<CGFloat>.size, value: &minimumLineHeight),
            CTParagraphStyleSetting(spec: .paragraphSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacing),
            CTParagraphStyleSetting(spec: .paragraphSpacingBefore, valueSize: MemoryLayout<CGFloat>.size, value: &paragraphSpacingBefore)
        ]
        
        let paragraphStyle = CTParagraphStyleCreate(styleSettings, styleSettings.count)
        CFDictionaryAddValue(styleDictionary, Unmanaged.passUnretained(kCTParagraphStyleAttributeName).toOpaque(), Unmanaged.passUnretained(paragraphStyle).toOpaque())
        CFAttributedStringSetAttributes(text, CFRange(location: position, length: length), styleDictionary, false)
    }
    
    // MARK: Font
    func applyItalicStyle(_ text: CFMutableAttributedString, position: Int, length: Int) {
        let actualTypeRef: CFTypeRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, nil)
        var italicFont = CTFontCreateCopyWithSymbolicTraits(actualTypeRef as! CTFont, 0.0, nil, .traitItalic, .traitItalic)
        if let ctFont = italicFont {
            // fallback to system italic font
            let uiFont = UIFont.italicSystemFont(ofSize: CTFontGetSize(ctFont))
            italicFont = CTFontCreateWithName(uiFont.fontName as CFString, uiFont.pointSize, nil)
        }
        
        CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTFontAttributeName, italicFont)
    }
    
    func applyBoldStyle(_ text: CFMutableAttributedString, position: Int, length: Int) {
        let actualTypeRef: CFTypeRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, nil)
        var boldFont = CTFontCreateCopyWithSymbolicTraits(actualTypeRef as! CTFont, 0.0, nil, .boldTrait, .boldTrait)
        if let ctFont = boldFont {
            // fallback to system bold font
            let uiFont = UIFont.italicSystemFont(ofSize: CTFontGetSize(ctFont))
            boldFont = CTFontCreateWithName(uiFont.fontName as CFString, uiFont.pointSize, nil)
        }
        
        CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTFontAttributeName, boldFont)
    }
    
    func applyBoldItalicStyle(_ text: CFMutableAttributedString, position: Int, length: Int) {
        let actualTypeRef = CFAttributedStringGetAttribute(text, position, kCTFontAttributeName, nil)
        var boldItalicFont = CTFontCreateCopyWithSymbolicTraits(actualTypeRef as! CTFont, 0.0, nil, CTFontSymbolicTraits(rawValue: CTFontSymbolicTraits.RawValue(UInt8(CTFontSymbolicTraits.boldTrait.rawValue) | UInt8(CTFontSymbolicTraits.italicTrait.rawValue))), CTFontSymbolicTraits(rawValue: CTFontSymbolicTraits.RawValue(UInt8(CTFontSymbolicTraits.boldTrait.rawValue) | UInt8(CTFontSymbolicTraits.italicTrait.rawValue))))
        
        if boldItalicFont == nil {
            // fallback to system bold font
            let fontName = "\(self.font.fontName)-BoldOblique"
            boldItalicFont = CTFontCreateWithName(fontName as CFString, self.font.pointSize, nil)
        }
        
        if boldItalicFont != nil {
            CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTFontAttributeName, boldItalicFont)
        }
    }
    
    func applyFontAttributes(_ attributes: [String: String]?, text: CFMutableAttributedString, position: Int, length: Int) {
        
        guard let attribu = attributes else {
            return
        }
        
        for (key, value) in attribu {
            let attribute = value.replacingOccurrences(of: "'", with: "")
            
            if key.caseInsensitiveCompare("color") == .orderedSame {
                applyColor(attribute, text: text, position: position, length: length)
            } else if key.caseInsensitiveCompare("stroke") == .orderedSame {
                let stroke = Int(attribu["stroke"]!)
                CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTStrokeWidthAttributeName, stroke as CFTypeRef)
            } else if key.caseInsensitiveCompare("kern") == .orderedSame {
                let kern = Int(attribu["kern"]!)
                CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTKernAttributeName, kern as CFTypeRef)
            } else if key.caseInsensitiveCompare("underline") == .orderedSame {
                let numberOfLines = Int(attribute)
                if numberOfLines == 1 {
                    applySingleUnderlineText(text, position: position, length: length)
                } else if numberOfLines == 2 {
                    applyDoubleUnderlineText(text, position: position, length: length)
                }
            } else if key.caseInsensitiveCompare("style") == .orderedSame {
                if value.caseInsensitiveCompare("bold") == .orderedSame {
                    applyBoldStyle(text, position: position, length: length)
                } else if value.caseInsensitiveCompare("italic") == .orderedSame {
                    applyItalicStyle(text, position: position, length: length)
                }
            }
        }
        
        var aFont: UIFont? = nil
        if let face = attributes?["face"], let size = attributes?["size"] {
            let fontName = face.replacingOccurrences(of: "'", with: "")
            let fontSize = Float(size)
            aFont = UIFont(name: fontName, size: CGFloat(fontSize!))
        } else if attributes?["face"] == nil, let size = attributes?["size"] {
            let fontSize = Float(size)
            aFont = UIFont(name: self.font.fontName, size: CGFloat(fontSize!))
        }
        
        if let font = aFont {
            let customFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
            CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTFontAttributeName, customFont)
        }
    }
    
    // MARK: Underline
    func applySingleUnderlineText(_ text: CFMutableAttributedString, position: Int, length: Int) {
        CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTUnderlineStyleAttributeName, CTUnderlineStyle.single.rawValue as CFTypeRef)
    }
    
    func applyDoubleUnderlineText(_ text: CFMutableAttributedString, position: Int, length: Int) {
        CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTUnderlineStyleAttributeName, CTUnderlineStyle.double.rawValue as CFTypeRef)
    }
    
    // MARK: Color
    func applyColor(_ value: String, text: CFMutableAttributedString, position: Int, length: Int) {
        var hexString = ""
        if value.range(of: "#")?.lowerBound.encodedOffset == 0 {
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            hexString = value.replacingOccurrences(of: "#", with: "")
            let components = color(forHex: hexString)
            let cgColor: CGColor = CGColor(colorSpace: rgbColorSpace, components: components)!
            CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTForegroundColorAttributeName, cgColor)
        } else {
            let color = value.appending("Color")
            let colorSEL: Selector = NSSelectorFromString(color)
            if UIColor.responds(to: colorSEL) {
                let uiColor = UIColor.perform(colorSEL).takeRetainedValue() as? UIColor
                let cgColor = uiColor?.cgColor
                CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTForegroundColorAttributeName, cgColor)
            }
        }
    }
    
    func applyUnderlineColor(_ text: CFMutableAttributedString, attributeValue: String, position: Int, length: Int) {
        var value = attributeValue.replacingOccurrences(of: "'", with: "")
        if value.range(of: "#")?.lowerBound.encodedOffset == 0 {
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            value = value.replacingOccurrences(of: "#", with: "0x")
            let colorComponents = color(forHex: value)
            let cgColor = CGColor(colorSpace: rgbColorSpace, components: colorComponents)
            CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTUnderlineColorAttributeName, cgColor)
        } else {
            let color = value.appending("Color")
            let colorSEL: Selector = NSSelectorFromString(color)
            if UIColor.responds(to: colorSEL) {
                let uiColor = UIColor.perform(colorSEL).takeRetainedValue() as? UIColor
                let cgColor = uiColor?.cgColor
                CFAttributedStringSetAttribute(text, CFRange(location: position, length: length), kCTForegroundColorAttributeName, cgColor)
            }
        }
    }
}

// MARK: Public method
extension VGLabel {
    
}

// MARK: extension HexString
extension VGLabel {
    func color(forHex hexString: String) -> [CGFloat] {
        let hexColor: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        let rIndex = hexColor.index(hexColor.startIndex, offsetBy: 2)
        let rString = String(hexColor[..<rIndex])
        
        let gStartIndex = hexColor.index(hexColor.startIndex, offsetBy: 2)
        let gEndIndex = hexColor.index(hexColor.endIndex, offsetBy: -2)
        let gString = String(hexColor[gStartIndex..<gEndIndex])
        
        let bString = String(hexColor[gEndIndex...])
        
        var r: Double = 0.0
        var g: Double = 0.0
        var b: Double = 0.0
        Scanner(string: "0x" + rString).scanHexDouble(&r)
        Scanner(string: "0x" + gString).scanHexDouble(&g)
        Scanner(string: "0x" + bString).scanHexDouble(&b)
        let components = [CGFloat(r / 255.0), CGFloat(g / 255.0), CGFloat(b / 255.0), CGFloat(1.0)]
        return components
    }
}

// MARK: Event
extension VGLabel {
    @objc func onButtonTouchDown(_ sender: VGLabelButton) {
        currentSelectedButtonComponentIndex = sender.componentIndex
        setNeedsDisplay()
    }
    
    @objc func onButtonTouchUpOutside(_ sender: VGLabelButton) {
        currentSelectedButtonComponentIndex = -1
        setNeedsDisplay()
    }
    
    @objc func onButtonPressed(_ sender: VGLabelButton) {
        currentSelectedButtonComponentIndex = -1
        setNeedsDisplay()
        
        delegate?.vgLabel(self, didSelectLink: sender.url)
    }
}
