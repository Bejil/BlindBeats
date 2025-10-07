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
			button.isHidden = user != BB_User.current
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
	private lazy var button:BB_Button = .init(String(key: "user.infos.name.button")) { [weak self] _ in
		
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
		
		add(button)
		
		addDismissButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func present(as style: BB_Alert_ViewController.Style = .Alert, withAnimation animated: Bool = true, _ completion: (() -> Void)? = nil) {
		
		super.present(as: .Sheet, withAnimation: true)
	}
}
