//
//  ExtensionString.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import Foundation

extension String {
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
    
    func convertHtml() -> NSAttributedString {
        let html = self.replacingOccurrences(of: "\n", with: "<br/>")
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
