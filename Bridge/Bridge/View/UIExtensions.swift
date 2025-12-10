//
//  UIExtensions.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

// MARK: - UIView Extensions
extension UIView {
    func anchorToSuperview(withInsets insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ])
    }
    
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    func applyCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func applyBorderStyling(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func applyShadowEffect(opacity: Float = 0.3, radius: CGFloat = 8, offset: CGSize = CGSize(width: 0, height: 4)) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    func animatePulse(duration: TimeInterval = 0.2, scale: CGFloat = 1.1) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: duration) {
                self.transform = .identity
            }
        }
    }
    
    func animateBounce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.2, 0.9, 1.05, 1.0]
        animation.keyTimes = [0, 0.2, 0.4, 0.6, 1.0]
        animation.duration = 0.5
        layer.add(animation, forKey: "bounce")
    }
    
    func animateFadeIn(duration: TimeInterval = 0.3) {
        alpha = 0
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
    
    func animateShake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, -10, 10, -10, 10, -5, 5, 0]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1]
        animation.duration = 0.5
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    static let mahjongPrimary = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
    static let mahjongSecondary = UIColor(red: 0.2, green: 0.8, blue: 1.0, alpha: 1.0) // Bright cyan for connection lines
    static let mahjongAccent = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
    static let mahjongSuccess = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
    static let mahjongBackground = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    static let mahjongOverlay = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    
    convenience init(hexString: String) {
        let hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// MARK: - UIFont Extensions
extension UIFont {
    static func mahjongTitle(size: CGFloat = 32) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    static func mahjongBody(size: CGFloat = 16) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func mahjongButton(size: CGFloat = 18) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
}

