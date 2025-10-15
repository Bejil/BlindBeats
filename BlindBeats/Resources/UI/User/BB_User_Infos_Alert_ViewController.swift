//
//  BB_User_Infos_Alert_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 30/09/2025.
//

import UIKit

public class BB_User_Infos_Alert_ViewController : BB_Alert_ViewController {
	
	public var user:BB_User? {
		
		didSet {
			
			title = user?.name
			userImageView.user = user
			levelLabel.text = String(key: "user.infos.level") + "\(BB_User.current?.level ?? 0)"
			levelProgressView.setProgress(user?.levelProgress ?? 0.0, animated: true)
			pointsLabel.text = "\(BB_User.current?.pointsToNextLevel ?? 0)" + String(key: "user.infos.points")
			
			attemptsLabel.text = String(key: "user.infos.stats.attempts") + "\(BB_User.current?.attemps ?? 0)"
			attemptsLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "user.infos.stats.attempts"))
			
			successLabel.text = String(key: "user.infos.stats.success") + "\(BB_User.current?.success ?? 0)"
			successLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "user.infos.stats.success"))
			
			failuresLabel.text = String(key: "user.infos.stats.failures") + "\(BB_User.current?.failures ?? 0)"
			failuresLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "user.infos.stats.failures"))
			
			if BB_User.current?.attemps ?? 0 > 0 {
				
				let successRate = Double(BB_User.current?.success ?? 0) / Double(BB_User.current?.attemps ?? 0) * 100
				successRateLabel.text = String(key: "user.infos.stats.successRate") + "\(String(format: "%.1f", successRate))%"
			}
			else {
				
				successRateLabel.text = String(key: "user.infos.stats.successRate") + "0%"
			}
			
			successRateLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "user.infos.stats.successRate"))
			
			nameButton.isHidden = user != BB_User.current
		}
	}
	private lazy var userImageView:BB_User_ImageView = .init()
	private lazy var levelLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.textColor = .white
		$0.textAlignment = .center
		return $0
		
	}(BB_Label())
	private lazy var levelProgressView:BB_ProgressView = {
		
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins)
		}
		return $0
		
	}(BB_ProgressView())
	private lazy var pointsLabel:BB_Label = {
		
		$0.textColor = .white
		$0.textAlignment = .center
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
	private lazy var nameButton:BB_Button = .init(String(key: "user.infos.name.button")) { [weak self] _ in
		
		self?.close {
			
			let alertController:BB_User_Name_Alert_ViewController = .init()
			alertController.backgroundView.isUserInteractionEnabled = true
			alertController.addCancelButton()
			alertController.present()
		}
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		let userImageViewContainer:UIView = .init()
		
		userImageViewContainer.addSubview(userImageView)
		userImageView.snp.makeConstraints { make in
			make.top.bottom.centerX.equalToSuperview()
		}
		add(userImageViewContainer)
		
		add(levelLabel)
		contentStackView.setCustomSpacing(3*UI.Margins/4, after: levelLabel)
		
		add(levelProgressView)
		contentStackView.setCustomSpacing(3*UI.Margins/4, after: levelProgressView)
		
		add(pointsLabel)
		
		let statsTitleLabel = BB_Label()
		statsTitleLabel.text = String(key: "user.infos.stats")
		statsTitleLabel.font = Fonts.Content.Title.H4
		statsTitleLabel.textColor = .white
		statsTitleLabel.textAlignment = .center
		
		let statsStackView = UIStackView(arrangedSubviews: [statsTitleLabel,successRateLabel,attemptsLabel, successLabel, failuresLabel])
		statsStackView.axis = .vertical
		statsStackView.setCustomSpacing(UI.Margins, after: statsTitleLabel)
		statsStackView.spacing = UI.Margins/2
		add(statsStackView)
		
		add(nameButton)
		
		addDismissButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func present(as style: BB_Alert_ViewController.Style = .Alert, withAnimation animated: Bool = true, _ completion: (() -> Void)? = nil) {
		
		super.present(as: .Sheet, withAnimation: true)
	}
}
