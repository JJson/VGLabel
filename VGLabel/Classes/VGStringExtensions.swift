//
//  VGStringExtensions.swift
//  VGLabel
//
//  Created by Vein on 2017/11/8.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

extension String {
    public func cgFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self) as? CGFloat
    }
}
