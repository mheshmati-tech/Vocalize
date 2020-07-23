//
//  ListViewCell.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/9/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import Foundation
import UIKit
class ListViewCell: UITableViewCell {

    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var transcriptionButton: UIButton!
    
    @IBOutlet weak var sentiment: UILabel!
}
