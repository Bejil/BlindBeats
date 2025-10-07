//
//  BB_Song_Selected_CollectionViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit
import MusicKit

public class BB_Song_Selected_CollectionViewCell: BB_CollectionViewCell {
	
	public class override var identifier:String {
		
		return "songSelectedCollectionViewCellIdentifier"
	}
	public var song:BB_Song? {
		
		didSet {
			
			playButton.song = song
			titleLabel.text = song?.title
			artistLabel.text = song?.artist
		}
	}
	private lazy var titleLabel: BB_Label = {
		
		$0.font = Fonts.Content.Title.H4.withSize(Fonts.Size)
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var artistLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		$0.alpha = 0.75
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var playButton:BB_Song_Play_Button = {
		
		$0.snp.remakeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}(BB_Song_Play_Button())
	public var deleteClosure:(()->Void)?
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		let backgroundView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .extraLight))
		backgroundView.clipsToBounds = true
		backgroundView.layer.cornerRadius = UI.CornerRadius
		contentView.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
		stackView.axis = .vertical
		
		let contentStackView = UIStackView(arrangedSubviews: [playButton,stackView])
		contentStackView.axis = .horizontal
		contentStackView.alignment = .center
		contentStackView.spacing = UI.Margins/2
		contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins/2)
		}
		
		let removeButton: UIButton = .init(type: .system)
		removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
		removeButton.tintColor = Colors.Button.Delete.Background
		removeButton.layer.cornerRadius = UI.CornerRadius
		removeButton.addAction(.init(handler: { [weak self] _ in
			
			self?.deleteClosure?()
			
		}), for: .touchUpInside)
		removeButton.snp.makeConstraints { make in
			make.size.equalTo(2*UI.CornerRadius)
		}
		contentView.addSubview(removeButton)
		removeButton.snp.makeConstraints { make in
			make.top.right.equalToSuperview().inset(-UI.Margins/2)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
