//
//  UIColor+Copper.swift
//  Copper
//
//  Created by Benjamin Sandofsky on 8/5/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: MainViewController
    
    class func sendButtonEnabledColor() -> UIColor {
        return UIColor.copper_primaryGreen()
    }
    
    class func sendButtonDisabledColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    // MARK: Brand colors below here.
    // See: https://www.dropbox.com/s/lmdim3pmo3mzt9a/copper-colors.sketch?dl=0
    
    // MARK: - Primary
    
    class func copper_primaryCopper() -> UIColor {
        return UIColor.hexStringToUIColor("D95C27")
    }
    
    class func copper_primaryGreen() -> UIColor {
        return UIColor.hexStringToUIColor("00D49F")
    }
    
    class func copper_primaryVerdigris() -> UIColor {
        return UIColor.hexStringToUIColor("14FFC4")
    }
    
    // MARK: - Secondary
    
    class func copper_secondaryBlue() -> UIColor {
        return UIColor.hexStringToUIColor("0A4BFF")
    }
    
    class func copper_secondaryPurple() -> UIColor {
        return UIColor.hexStringToUIColor("6614F5")
    }
    
    class func copper_secondaryPink() -> UIColor {
        return UIColor.hexStringToUIColor("FF309F")
    }
    
    class func copper_secondaryRed() -> UIColor {
        return UIColor.hexStringToUIColor("F52229")
    }
    
    class func copper_secondaryOrange() -> UIColor {
        return UIColor.hexStringToUIColor("FF620D")
    }
    
    class func copper_secondaryYellow() -> UIColor {
        return UIColor.hexStringToUIColor("FFD500")
    }
    
    // MARK: - Soft palatte
    
    class func copper_softGreen() -> UIColor {
        return UIColor.hexStringToUIColor("93F5D4")
    }
    
    class func copper_softBlue() -> UIColor {
        return UIColor.hexStringToUIColor("A8E8FF")
    }
    
    class func copper_softPurple() -> UIColor {
        return UIColor.hexStringToUIColor("CCCCFF")
    }
    
    class func copper_softPink() -> UIColor {
        return UIColor.hexStringToUIColor("FFC7E5")
    }
    
    class func copper_softOrange() -> UIColor {
        return UIColor.hexStringToUIColor("FFC3B8")
    }
    
    class func copper_softYellow() -> UIColor {
        return UIColor.hexStringToUIColor("FFE0B8")
    }
    
    // MARK: - Dark Palatte
    
    class func copper_darkGreen() -> UIColor {
        return UIColor.hexStringToUIColor("00664B")
    }
    
    class func copper_darkBlue() -> UIColor {
        return UIColor.hexStringToUIColor("1D2C8F")
    }
    
    class func copper_darkPurple() -> UIColor {
        return UIColor.hexStringToUIColor("65177A")
    }
    
    class func copper_darkBrown() -> UIColor {
        return UIColor.hexStringToUIColor("662C1D")
    }
    
    // MARK: - Black Palatte
    
    class func copper_black() -> UIColor {
        return UIColor.hexStringToUIColor("000000")
    }
    
    class func copper_black92() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.92)
    }
    
    class func copper_black60() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.60)
    }
    
    class func copper_black40() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.40)
    }
    
    class func copper_black20() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.20)
    }
    
    class func copper_black08() -> UIColor {
        return UIColor.hexStringToUIColor("000000").colorWithAlphaComponent(0.08)
    }
    
    // MARK: - White palatte
    
    class func copper_white() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF")
    }
    
    class func copper_white95() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.95)
    }
    
    class func copper_white72() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.72)
    }
    
    class func copper_white52() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.52)
    }
    
    class func copper_white32() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.32)
    }
    
    class func copper_white20() -> UIColor {
        return UIColor.hexStringToUIColor("FFFFFF").colorWithAlphaComponent(0.20)
    }
    
    // MARK: - Helper methods
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}