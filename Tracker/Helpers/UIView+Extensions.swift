//
//  UIView+Extensions.swift
//  Tracker
//
//  Created by big stepper on 08/10/2024.
//

import UIKit


extension UIView {
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    public func addSubviews(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
    
    public func rounded() {
        layer.masksToBounds = false
        layer.cornerRadius = self.frame.height / 2
        clipsToBounds = true
    }
}
