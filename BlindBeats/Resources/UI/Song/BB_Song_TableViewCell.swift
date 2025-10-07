//
//  BB_SongTableViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit
import MusicKit

public class BB_Song_TableViewCell: BB_TableViewCell {
	
	public override class var identifier: String {
		
		return "songTableViewCellIdentifier"
	}
	public var song:BB_Song? {
		
		didSet {
			
			coverImageView.url = song?.coverUrl
			titleLabel.text = song?.title
			artistLabel.text = song?.artist
			albumLabel.text = song?.album
			playButton.song = song
		}
	}
	private lazy var titleLabel: BB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var artistLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-1)
		$0.alpha = 0.75
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var albumLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.alpha = 0.5
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var playButton: BB_Song_Play_Button = .init()
	private lazy var selectionImageView: BB_ImageView = {
		
		$0.tintColor = Colors.Tertiary
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "circle")))
	private lazy var coverImageView: BB_ImageView = {
		
		$0.contentMode = .scaleAspectFill
		$0.layer.cornerRadius = UI.CornerRadius/2
		$0.clipsToBounds = true
		$0.backgroundColor = .systemGray6
		$0.snp.makeConstraints { make in
			make.size.equalTo(3*UI.Margins)
		}
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "music.quarternote.3")))
	public override var isSelected: Bool {
		
		didSet {
			
			selectionImageView.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
		}
	}
	private var isPlaying: Bool = false {
		
		didSet {
			
			playButton.isPlaying = isPlaying
		}
	}
	public override var isEditing:Bool {
		
		didSet {
			
			selectionImageView.isHidden = !isEditing
		}
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		selectionStyle = .none
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [titleLabel,artistLabel,albumLabel])
		contentStackView.axis = .vertical
		
		let stackView:UIStackView = .init(arrangedSubviews: [selectionImageView,coverImageView,contentStackView,playButton])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		NotificationCenter.add(.updateSongStatus, { [weak self] _ in
				
			self?.isPlaying = BB_Audio.shared.isPlayingPreview(for: self?.song)
		})
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
