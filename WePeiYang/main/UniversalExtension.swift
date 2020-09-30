//
//  UniversalExtension.swift
//  WePeiYang
//
//  Created by Halcao on 2018/3/13.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import UIKit

extension String {
     var sha1: String {
          let data = self.data(using: String.Encoding.utf8)!
          var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
          data.withUnsafeBytes {
               _ = CC_SHA1($0, CC_LONG(data.count), &digest)
          }
          let hexBytes = digest.map { String(format: "%02hhx", $0) }
          return hexBytes.joined()
     }
     func getSuitableHeight(font: UIFont, setWidth: CGFloat, numbersOfLines: Int) -> CGFloat {
          let label = UILabel(frame: CGRect(x: 0, y: 0, width: setWidth, height: CGFloat.greatestFiniteMagnitude))
          label.numberOfLines = numbersOfLines
          label.font = font
          label.text = self
          
          label.sizeToFit()
          return label.bounds.height
     }
     var htmlToAttributedString: NSAttributedString? {
          guard let data = data(using: .utf8) else { return nil }
          do {
               return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
          } catch {
               return nil
          }
     }
     var htmlToString: String {
          return htmlToAttributedString?.string ?? ""
     }
     subscript (i: Int) -> Character? {
          guard i < self.count else {
               return nil
          }
          return self[self.index(self.startIndex, offsetBy: i)]
     }
     
     subscript (r: Range<Int>) -> String? {
          guard (r.lowerBound >= 0 && r.upperBound <= self.count) else { return nil }
          let start = index(startIndex, offsetBy: r.lowerBound)
          let end = index(startIndex, offsetBy: r.upperBound)
          return String(self[start..<end])
     }
     
     subscript (r: ClosedRange<Int>) -> String? {
          guard (r.lowerBound >= 0 && r.upperBound < self.count) else { return nil }
          let start = index(startIndex, offsetBy: r.lowerBound)
          let end = index(startIndex, offsetBy: r.upperBound)
          return String(self[start...end])
     }
     func findFirst(_ sub:String)->Int {
          var pos = -1
          if let range = range(of:sub, options: .literal ) {
               if !range.isEmpty {
                    pos = self.distance(from:startIndex, to:range.lowerBound)
               }
          }
          return pos
     }
     
}

extension UIFont {
     //    #define kScreenWidthRatio  (UIScreen.mainScreen.bounds.size.width / 375.0)
     //    #define kScreenHeightRatio (UIScreen.mainScreen.bounds.size.height / 667.0)
     //    #define AdaptedWidth(x)  ceilf((x) * kScreenWidthRatio)
     static func flexibleSystemFont(ofSize size: CGFloat) -> UIFont {
          var size = size
          if UIDevice.current.model != "iPad" {
               size = (UIScreen.main.bounds.size.width / 375.0) * size
          }
          return UIFont.systemFont(ofSize: size)
     }
     
     static func flexibleSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
          var size = size
          if UIDevice.current.model != "iPad" {
               size = (UIScreen.main.bounds.size.width / 375.0) * size
          }
          return UIFont.systemFont(ofSize: size, weight: weight)
     }
}

//自定义设置圆角, 阴影
extension UIView {
     func addCorner(roundingCorners: UIRectCorner, cornerSize: CGSize) {
          let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
          let cornerLayer = CAShapeLayer()
          cornerLayer.frame = bounds
          cornerLayer.path = path.cgPath
          layer.mask = cornerLayer
     }
     func addCornerRadius(_ radius: CGFloat) {
          self.layer.cornerRadius = radius
          self.layer.masksToBounds = true
     }
     func addShadow(_ sColor: UIColor, sRadius: CGFloat, sOpacity: Float, offset: (CGFloat, CGFloat), for changedRect: CGRect = .zero) {
          let rect = changedRect == .zero ? self.bounds : changedRect
          self.layer.shadowColor = sColor.cgColor
          self.layer.shadowRadius = sRadius
          self.layer.shadowOpacity = sOpacity
          // 设置 shadowOffset 会产生离屏渲染
          self.layer.shadowOffset = .zero
          let path = UIBezierPath(roundedRect: rect.offsetBy(dx: offset.0, dy: offset.1), cornerRadius: self.layer.cornerRadius)
          self.layer.shadowPath = path.cgPath
          self.layer.masksToBounds = false
     }
}
