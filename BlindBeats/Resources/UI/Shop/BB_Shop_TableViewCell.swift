//
//  BB_Shop_TableViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 06/10/2025.
//

import UIKit
import StoreKit

public class BB_Shop_TableViewCell : BB_TableViewCell {
	
	public override class var identifier: String {
		
		return "shopTableViewCellIdentifier"
	}
	
	public var product:Product? {
		
		didSet {
			
			titleLabel.text = product?.displayName
			descriptionLabel.text = product?.description
			priceButton.title = product?.displayPrice
		}
	}
	private lazy var titleLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BB_Label())
	private lazy var descriptionLabel:BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BB_Label())
	private lazy var priceButton:BB_Button = {
		
		$0.titleLabel?.font = Fonts.Content.Title.H4
		$0.isUserInteractionEnabled = false
		return $0
		
	}(BB_Button())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let backgroundVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .prominent))
		backgroundVisualEffectView.layer.cornerRadius = UI.CornerRadius
		backgroundVisualEffectView.layer.masksToBounds = true
		contentView.addSubview(backgroundVisualEffectView)
		backgroundVisualEffectView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.right.equalToSuperview()
		}
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [titleLabel,descriptionLabel])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins/2
		
		let stackView:UIStackView = .init(arrangedSubviews: [contentStackView,priceButton])
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
