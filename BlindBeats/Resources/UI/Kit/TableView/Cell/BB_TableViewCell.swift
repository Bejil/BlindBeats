//
//  BB_TableViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit

public class BB_TableViewCell: UITableViewCell {
	
	public class var identifier: String {
		
		return "tableViewCellIdentifier"
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .clear
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
	
	public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
		super.setHighlighted(highlighted, animated: animated)
		
		if !isEditing && selectionStyle != .none {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
				
				self.transform = highlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
				
			}, completion: nil)
		}
	}
}
