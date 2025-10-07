//
//  BB_Song_StackView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 27/09/2025.
//

import UIKit

public class BB_Song_StackView : UIStackView {
	
	public var song:BB_Song? {
		
		didSet {
			
			coverImageView.url = song?.coverUrl
			titleLabel.text = song?.title
			artistLabel.text = song?.artist
		}
	}
	public lazy var titleLabel: BB_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textAlignment = .center
		return $0
		
	}(BB_Label())
	public lazy var artistLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textColor = $0.textColor.withAlphaComponent(0.75)
		$0.textAlignment = .center
		return $0
		
	}(BB_Label())
	public lazy var coverView: UIView = {
		
		$0.snp.makeConstraints { make in
			make.size.equalTo(10*UI.Margins)
		}
		
		$0.addSubview(coverImageView)
		coverImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		return $0
		
	}(UIView())
	public lazy var coverImageView: BB_ImageView = {
		
		$0.contentMode = .scaleAspectFill
		$0.layer.cornerRadius = UI.CornerRadius/2
		$0.clipsToBounds = true
		$0.backgroundColor = .systemGray6
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "music.quarternote.3")))
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/2
		alignment = .center
		addArrangedSubview(coverView)
		addArrangedSubview(titleLabel)
		addArrangedSubview(artistLabel)
		setCustomSpacing(1.5*UI.Margins, after: coverView)
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
