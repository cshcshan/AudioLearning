//
//  ExtensionString.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.date(from: self)
    }
    
    func convertHtml(backgroundColor: UIColor? = nil, fontColor: UIColor? = nil, fontName: String? = nil, fontSize: CGFloat? = nil) -> NSAttributedString {
        var html = self.replacingOccurrences(of: "\n", with: "<br/>")
        if backgroundColor != nil || fontColor != nil || fontName != nil || fontSize == nil {
            var style = ""
            if let backgroundColor = backgroundColor { style += "background-color:\(backgroundColor.hexString);" }
            if let fontColor = fontColor { style += "color:\(fontColor.hexString);" }
            if let fontName = fontName { style += "font-family:'\(fontName)';" }
            if let fontSize = fontSize { style += "font-size:\(fontSize)px;" }
            html = "<style>body{\(style)}</style>\(html)"
        }
        guard let data = html.data(using: .utf8) else { return NSAttributedString() }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any]
            = [.documentType: NSAttributedString.DocumentType.html,
               .characterEncoding: String.Encoding.utf8.rawValue]
        guard let attrStr
            = try? NSAttributedString(data: data, options: options,
                                      documentAttributes: nil) else { return NSAttributedString() }
        return attrStr
    }
}
