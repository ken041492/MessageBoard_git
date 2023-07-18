//
//  MainTableViewCell.swift
//  chattingprac
//
//  Created by imac-1682 on 2023/7/12.
//

import UIKit
class MainTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var label2: UILabel?
    
    static let identified = "MainTableView"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
