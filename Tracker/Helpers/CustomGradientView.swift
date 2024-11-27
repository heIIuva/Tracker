//
//  CustomGradientView.swift
//  Tracker
//
//  Created by big stepper on 27/11/2024.
//

import UIKit

final class CustomGradientView: UIView {

    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    //MARK: - Properties
    
    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    
    //MARK: - Methods

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.992, green: 0.298, blue: 0.287, alpha: 1.0).cgColor,
            UIColor(red: 0.275, green: 0.902, blue: 0.616, alpha: 1.0).cgColor,
            UIColor(red: 0.0, green: 0.482, blue: 0.980, alpha: 1.0).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.526, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let insetRect = bounds.insetBy(dx: 1, dy: 1)
        let innerPath = UIBezierPath(roundedRect: insetRect, cornerRadius: layer.cornerRadius)
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)

        maskLayer.path = outerPath.cgPath
        maskLayer.fillRule = .evenOdd

        let combinedPath = UIBezierPath()
        combinedPath.append(outerPath)
        combinedPath.append(innerPath.reversing())

        borderLayer.path = combinedPath.cgPath
        borderLayer.fillColor = UIColor.white.cgColor
        gradientLayer.mask = borderLayer
    }
}
