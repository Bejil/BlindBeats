//
//  BB_Playlist_Stats_AlertViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/10/2025.
//

import UIKit

public class BB_Playlist_Stats_AlertViewController: BB_Alert_ViewController {
	
	public var playlist: BB_Playlist? {
		
		didSet {
			
			title = playlist?.title
			
			difficultyLabel.backgroundColor = playlist?.difficulty.color
			difficultyLabel.text = String(key: "playlists.difficulty." + (playlist?.difficulty.rawValue ?? BB_Playlist.Difficulty.unknown.rawValue))
			
			attemptsLabel.text = String(key: "playlists.stats.attempts") + "\(playlist?.attemps ?? 0)"
			attemptsLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "playlists.stats.attempts"))
			
			successLabel.text = String(key: "playlists.stats.success") + "\(playlist?.success ?? 0)"
			successLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "playlists.stats.success"))
			
			failuresLabel.text = String(key: "playlists.stats.failures") + "\(playlist?.failures ?? 0)"
			failuresLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "playlists.stats.failures"))
			
			if playlist?.attemps ?? 0 > 0 {
				
				let successRate = Double(playlist?.success ?? 0) / Double(playlist?.attemps ?? 0) * 100
				successRateLabel.text = String(key: "playlists.stats.successRate") + "\(String(format: "%.1f", successRate))%"
			}
			else {
				
				successRateLabel.text = String(key: "playlists.stats.successRate") + "0%"
			}
			
			successRateLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "playlists.stats.successRate"))
		}
	}
	private lazy var difficultyLabel: BB_Label = {
		
		$0.layer.cornerRadius = UI.Margins/2
		$0.contentInsets = .init(horizontal: UI.Margins/5, vertical: UI.Margins/7)
		$0.textAlignment = .center
		$0.textColor = .white
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		return $0
		
	}(BB_Label())
	private lazy var attemptsLabel: BB_Label = {
		
		$0.textAlignment = .center
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var successLabel: BB_Label = {
		
		$0.textAlignment = .center
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var failuresLabel: BB_Label = {
		
		$0.textAlignment = .center
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var successRateLabel: BB_Label = {
		
		$0.textAlignment = .center
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		let difficultyView:UIView = .init()
		difficultyView.addSubview(difficultyLabel)
		difficultyLabel.snp.makeConstraints { make in
			make.top.bottom.centerX.equalToSuperview()
			make.width.lessThanOrEqualToSuperview()
		}
		add(difficultyView)
		
		let statsTitleLabel = BB_Label()
		statsTitleLabel.text = String(key: "playlists.stats.statistics")
		statsTitleLabel.font = Fonts.Content.Title.H4
		statsTitleLabel.textColor = .white
		statsTitleLabel.textAlignment = .center
		
		let statsStackView = UIStackView(arrangedSubviews: [statsTitleLabel,successRateLabel,attemptsLabel, successLabel, failuresLabel])
		statsStackView.axis = .vertical
		statsStackView.setCustomSpacing(UI.Margins, after: statsTitleLabel)
		statsStackView.spacing = UI.Margins/2
		add(statsStackView)
		
		addDismissButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
