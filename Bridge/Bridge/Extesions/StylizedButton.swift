//
//  StylizedButton.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

class StylizedButton: UIButton {
    
    enum ButtonVariant {
        case primary
        case secondary
        case accent
        case transparent
        
        var backgroundColor: UIColor {
            switch self {
            case .primary: return UIColor.mahjongPrimary
            case .secondary: return UIColor.mahjongSecondary
            case .accent: return UIColor.mahjongAccent
            case .transparent: return UIColor.clear
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .transparent: return .white
            default: return .white
            }
        }
    }
    
    init(title: String, variant: ButtonVariant = .primary) {
        super.init(frame: .zero)
        configureAppearance(title: title, variant: variant)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance(title: String, variant: ButtonVariant) {
        setTitle(title, for: .normal)
        setTitleColor(variant.textColor, for: .normal)
        titleLabel?.font = .mahjongButton()
        backgroundColor = variant.backgroundColor
        
        applyCornerRadius(12)
        
        if variant != .transparent {
            applyShadowEffect(opacity: 0.2, radius: 6)
        } else {
            applyBorderStyling(width: 2, color: .white)
        }
        
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        }
    }
    
    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - Custom Back Button
class NavigationReturnButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppearance() {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.left", withConfiguration: configuration)
        
        setImage(chevronImage, for: .normal)
        tintColor = .white
        backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        
        applyCornerRadius(22)
        applyBorderStyling(width: 1.5, color: UIColor(white: 1.0, alpha: 0.3))
        
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.7
        }
    }
    
    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

