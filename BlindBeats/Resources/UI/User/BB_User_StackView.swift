//
//  BB_User_StackView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit

public class BB_User_StackView : UIStackView {
	
	private lazy var imageView:BB_User_ImageView = {
		
		$0.user = BB_User.current
		return $0
		
	}(BB_User_ImageView())
	private lazy var nameLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.numberOfLines = 1
		$0.text = BB_User.current?.name
		$0.textColor = .white
		return $0
		
	}(BB_Label(BB_User.current?.name))
	private lazy var diamondsLabel:BB_Label = {
		
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.backgroundColor = .white
		$0.layer.cornerRadius = UI.Margins/2
		$0.contentInsets = .init(horizontal: UI.Margins/5, vertical: UI.Margins/7)
		$0.textAlignment = .center
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		return $0
		
	}(BB_Label("\(BB_User.current?.diamonds ?? 0) " + String(key: "user.diamonds")))
	private lazy var levelLabel:BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.numberOfLines = 1
		$0.textColor = .white
		return $0
		
	}(BB_Label(String(key: "user.infos.level") + "\(BB_User.current?.level ?? 0)"))
	private lazy var progressView:BB_ProgressView = {
		
		$0.setProgress(BB_User.current?.levelProgress ?? 0.0, animated: true)
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins/2)
		}
		return $0
		
	}(BB_ProgressView())
	private lazy var backgroundShapeLayer:CAShapeLayer = {
		
		$0.fillColor = Colors.Primary.cgColor
		$0.shadowOffset = .zero
		$0.shadowRadius = UI.CornerRadius
		$0.shadowOpacity = 0.25
		$0.masksToBounds = false
		$0.shadowColor = UIColor.black.cgColor
		return $0
		
	}(CAShapeLayer())
	
	public override init(frame: CGRect) {
	
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins
		alignment = .center
		layer.addSublayer(backgroundShapeLayer)
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: 3*UI.Margins)
		layoutMargins.bottom = safeAreaInsets.bottom + UI.Margins
		layoutMargins.top = 2*UI.Margins
		
		addArrangedSubview(imageView)
		
		let button:UIButton = .init()
		button.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
		button.tintColor = .white
		button.addAction(.init(handler: { _ in
			
			UIApplication.feedBack(.On)
			BB_Sound.shared.playSound(.Button)
			
			let alertViewController:BB_User_Infos_Alert_ViewController = .init()
			alertViewController.user = BB_User.current
			alertViewController.present()
			
		}), for: .touchUpInside)
		button.snp.makeConstraints { make in
			make.size.equalTo(1.5*UI.Margins)
		}
		
		let nameStackView:UIStackView = .init(arrangedSubviews: [nameLabel,diamondsLabel,button])
		nameStackView.axis = .horizontal
		nameStackView.alignment = .center
		nameStackView.spacing = 2*UI.Margins/3
		
		let levelStackView:UIStackView = .init(arrangedSubviews: [levelLabel,progressView])
		levelStackView.axis = .horizontal
		levelStackView.spacing = UI.Margins
		levelStackView.alignment = .center
		
		let stackView:UIStackView = .init(arrangedSubviews: [nameStackView,levelStackView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins/2
		addArrangedSubview(stackView)
		
		NotificationCenter.add(.updateUser) { [weak self] _ in
			
			self?.imageView.user = BB_User.current
			self?.nameLabel.text = BB_User.current?.name
			self?.diamondsLabel.text = "\(BB_User.current?.diamonds ?? 0) " + String(key: "user.diamonds")
			self?.levelLabel.text = String(key: "user.infos.level") + "\(BB_User.current?.level ?? 0)"
			self?.progressView.setProgress(BB_User.current?.levelProgress ?? 0.0, animated: true)
		}
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: .init(x: 0, y: UI.Margins/2))
		bezierPath.addLine(to: .init(x: frame.size.width, y: 0))
		bezierPath.addLine(to: .init(x: frame.size.width, y: frame.size.height))
		bezierPath.addLine(to: .init(x: 0, y: frame.size.height))
		bezierPath.close()
		backgroundShapeLayer.path = bezierPath.cgPath
	}
}
