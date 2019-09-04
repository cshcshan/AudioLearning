//
//  EpisodeCell.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/4.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var episodeModel: EpisodeModel? {
        didSet {
            bindUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func bindUI() {
        titleLabel?.text = episodeModel?.title
        dateLabel?.text = episodeModel?.date?.toString(dateFormat: "yyyy/M/d")
        descLabel?.text = episodeModel?.desc
    }
}
