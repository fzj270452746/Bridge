//
//  DeviceAdaptation.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

// MARK: - Device Type Detection
enum DeviceCategory {
    case phone
    case pad
    
    static var current: DeviceCategory {
        return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
    }
}

// MARK: - Adaptive Sizing
struct AdaptiveDimensions {
    
    static func horizontalPadding() -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return 40
        case .pad: return 100
        }
    }
    
    static func buttonHeight() -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return 60
        case .pad: return 70
        }
    }
    
    static func titleFontSize() -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return 28
        case .pad: return 36
        }
    }
    
    static func bodyFontSize() -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return 16
        case .pad: return 20
        }
    }
    
    static func tileContainerWidth(viewWidth: CGFloat) -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return viewWidth * 0.35
        case .pad: return min(viewWidth * 0.3, 250)
        }
    }
    
    static func stackSpacing() -> CGFloat {
        switch DeviceCategory.current {
        case .phone: return 30
        case .pad: return 40
        }
    }
}

