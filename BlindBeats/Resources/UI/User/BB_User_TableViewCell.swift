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
	public var user:BB_User? {
		
		didSet {
			
			userImageView.user = user
			nameLabel.text = user?.name
		}
	}
	private lazy var userImageView:BB_User_ImageView = {
		
		let height = 2*UI.Margins
		$0.snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		$0.layer.cornerRadius = height/2
		return $0
		
	}(BB_User_ImageView())
	private lazy var nameLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let backgroundVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .prominent))
		backgroundVisualEffectView.layer.cornerRadius = UI.CornerRadius
		backgroundVisualEffectView.layer.masksToBounds = true
		contentView.addSubview(backgroundVisualEffectView)
		backgroundVisualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins/2)
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [userImageView,nameLabel])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		backgroundVisualEffectView.contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
