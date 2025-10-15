//
//  BB_User_TableViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit

public class BB_User_TableViewCell : BB_TableViewCell {
	
	public override class var identifier: String {
		
		return "userTableViewCellIdentifier"
	}
	public var rank:Int? {
		
		didSet {
			
			if let rank {
				
				rankLabel.text = "\(rank)"
			}
			else {
				
				rankLabel.text = "n/c"
			}
		}
	}
	public var user:BB_User? {
		
		didSet {
			
			rankLabel.backgroundColor = user == BB_User.current ? Colors.Secondary : Colors.Primary
			userImageView.user = user
			nameLabel.text = user?.name
		}
	}
	private lazy var rankLabel:BB_Label = { label in
		
		label.layer.cornerRadius = UI.CornerRadius
		label.textAlignment = .center
		label.font = Fonts.Content.Title.H4
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.25
		label.textColor = .white
		label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		return label
		
	}(BB_Label())
	private lazy var userImageView:BB_User_ImageView = {
		
		let height = 2.5*UI.Margins
		$0.snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		$0.layer.cornerRadius = height/2
		return $0
		
	}(BB_User_ImageView())
	private lazy var nameLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		accessoryType = .detailDisclosureButton
		
		let backgroundVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .prominent))
		backgroundVisualEffectView.layer.cornerRadius = UI.CornerRadius
		backgroundVisualEffectView.layer.masksToBounds = true
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [userImageView,nameLabel])
		contentStackView.axis = .horizontal
		contentStackView.spacing = UI.Margins
		contentStackView.alignment = .center
		backgroundVisualEffectView.contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins/2)
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankLabel,backgroundVisualEffectView])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .fill
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.equalToSuperview()
			make.right.equalToSuperview().inset(UI.Margins)
		}
		
		rankLabel.snp.makeConstraints { make in
			make.width.greaterThanOrEqualTo(rankLabel.snp.height)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
