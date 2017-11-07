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
    func vgLabel(_ label: VGLabel, didSelectLink URL: URL)
}

public extension VGLabelDelegate {
    func vgLabel(_ label: VGLabel, didSelectLink URL: URL) {}
}

open class VGLabel: UIView {
    open var text: String
    open var plainText: String?
    open var highlightedText: String?
    open var textColor: UIColor
    open var font: UIFont
    open var linkAttributes: [NSAttributedStringKey: Any]?
    open var selectedLinkAttributes: [NSAttributedStringKey: Any]?
    open weak var delegate: VGLabelDelegate?
    open var paragraphReplacement: String
    open var textComponents: [VGLabelComponent]?
    open var highlightedTextComponents: [VGLabelComponent]?
    open var textAlignment: VGTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var optimumSize: CGSize?
    open var lineBreakMode: VGLineBreakMode {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var lineSpacing: CGFloat
    open var currentSelectedButtonComponentIndex: Int
    open var visibleRange: CFRange?
    open var highlighted: Bool?
    
    public override init(frame: CGRect) {
        font = UIFont.systemFont(ofSize: 15)
        textColor = UIColor.black
        text = ""
        textAlignment = .left
        lineBreakMode = .byWordWrapping
        lineSpacing = 3
        currentSelectedButtonComponentIndex = -1
        paragraphReplacement = "\n"
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
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        isMultipleTouchEnabled = true
    }
    
    open override func draw(_ rect: CGRect) {
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
        
        let context = UIGraphicsGetCurrentContext()
        if context != nil {
            
        }
    }
}
