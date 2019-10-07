//
//  ExtensionUITableView.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/7.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

extension UITableView {
    
    private var tagOfEmptyView: Int {
        return 101
    }
    
    func showEmptyView(_ backgroundColor: UIColor?,
                       title: (text: String?, color: UIColor?),
                       message: (text: String?, color: UIColor?)) {
        
        var emptyView: UIView!
        if let bgView = self.backgroundView, bgView.tag == tagOfEmptyView {
            emptyView = backgroundView
        }
        if emptyView == nil {
            emptyView = UIView(frame: self.bounds)
            emptyView.tag = tagOfEmptyView
        }
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        emptyView.backgroundColor = backgroundColor
        
        titleLabel.text = title.text
        titleLabel.textColor = title.color
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabel.numberOfLines = 0
        messageLabel.text = message.text
        messageLabel.textColor = message.color
        messageLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18.0)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        let views = ["title": titleLabel, "message": messageLabel]
        let titleCenterX = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[title]-10-|",
                                                             options: [], metrics: nil, views: views)
        let messageCenterX = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[message]-10-|",
                                                               options: [], metrics: nil, views: views)
        let titleCenterY = NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: emptyView, attribute: .centerY, multiplier: 1, constant: -20)
        let messageCenterY = NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: emptyView, attribute: .centerY, multiplier: 1, constant: 20)
        emptyView.addConstraints(titleCenterX + messageCenterX + [titleCenterY, messageCenterY])
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func hideEmptyView(_ originalBackgroundView: UIView?, separatorStyle: UITableViewCell.SeparatorStyle) {
        self.backgroundView = originalBackgroundView
        self.separatorStyle = separatorStyle
    }
}
