//
//  MapTypeCell.swift
//  Example
//
//  Created by Josef Dolezal on 06/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import UIKit

final class MapTypeCell: UITableViewCell {
    // MARK: Properties

    static let identifier = "MapTypeCell"

    // MARK: Initializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
