//
//  BB_Toast_StackView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 08/10/2025.
//

import UIKit

public class BB_Toast_StackView : UIStackView {
	
	public enum Position: CaseIterable {
		
		case Top
		case Bottom
		case Center
		case Left
		case Right
	}
	
	public enum Direction: CaseIterable {
		
		case Top
		case Bottom
		case Center
		case Left
		case Right
	}
	
	public enum Style: CaseIterable {
		
		case Success
		case Info
		case Warning
		case Failure
	}
	
	public var style:Style = .Info {
		
		didSet {
			
			update()
		}
	}
	private lazy var backgroundView:UIView = .init()
	private lazy var imageContentView:UIView = {
		
		$0.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins/2)
		}
		return $0
		
	}(BB_ImageView())
	private lazy var imageView:BB_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BB_ImageView())
	public var image:UIImage? {
		
		didSet {
			
			update()
		}
	}
	private lazy var titleLabel:BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-1)
		return $0
		
	}(BB_Label())
	public var title:String? {
		
		didSet {
			
			update()
		}
	}
	private lazy var subtitleLabel:BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(BB_Label())
	public var subtitle:String? {
		
		didSet {
			
			update()
		}
	}
	private lazy var contentStackView:UIStackView = {
		
		$0.axis = .vertical
		return $0
		
	}(UIStackView(arrangedSubviews: [titleLabel,subtitleLabel]))
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		clipsToBounds = true
		layer.cornerRadius = UI.CornerRadius
		backgroundColor = .white
		axis = .horizontal
		spacing = UI.Margins
		alignment = .center
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(3*UI.Margins/4)
		
		addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		addArrangedSubview(imageContentView)
		addArrangedSubview(contentStackView)
		
		imageContentView.snp.makeConstraints { make in
			make.size.equalTo(contentStackView.snp.height)
		}
	}
	
	required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		imageContentView.layer.cornerRadius = imageContentView.frame.size.height/2
	}
	
	private func update() {
		
		switch style {
		case .Success:
			backgroundView.backgroundColor = Colors.Toast.Success.withAlphaComponent(0.2)
			imageContentView.backgroundColor = Colors.Toast.Success
			imageView.image = imageView.image ?? UIImage(systemName: "checkmark")
		case .Info:
			backgroundView.backgroundColor = Colors.Toast.Info.withAlphaComponent(0.2)
			imageContentView.backgroundColor = Colors.Toast.Info
			imageView.image = imageView.image ?? UIImage(systemName: "info")
		case .Warning:
			backgroundView.backgroundColor = Colors.Toast.Warning.withAlphaComponent(0.2)
			imageContentView.backgroundColor = Colors.Toast.Warning
			imageView.image = imageView.image ?? UIImage(systemName: "exclamationmark")
		case .Failure:
			backgroundView.backgroundColor = Colors.Toast.Failure.withAlphaComponent(0.2)
			imageContentView.backgroundColor = Colors.Toast.Failure
			imageView.image = imageView.image ?? UIImage(systemName: "xmark")
		}
		
		titleLabel.text = title
		subtitleLabel.text = subtitle
	}
	
	public func present(sourceView:UIView, position:Position = .Top, from:Direction = .Bottom, to:Direction = .Bottom) {
		
		present(in: UI.MainController.view, sourceView: sourceView, position: position, from: from, to: to)
	}
	
	public func present(in containerView:UIView, position:Position = .Top, from:Direction = .Bottom, to:Direction = .Bottom) {
		
		containerView.addSubview(self)
		
		translatesAutoresizingMaskIntoConstraints = false
		alpha = 0
		
		switch position {
		case .Top:
			snp.makeConstraints { make in
				make.top.equalTo(containerView.safeAreaLayoutGuide).offset(UI.Margins)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Bottom:
			snp.makeConstraints { make in
				make.bottom.equalTo(containerView.safeAreaLayoutGuide).offset(-UI.Margins)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Center:
			snp.makeConstraints { make in
				make.centerY.equalTo(containerView)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Left:
			snp.makeConstraints { make in
				make.left.equalTo(containerView).offset(UI.Margins)
				make.centerY.equalTo(containerView)
			}
		case .Right:
			snp.makeConstraints { make in
				make.right.equalTo(containerView).offset(-UI.Margins)
				make.centerY.equalTo(containerView)
			}
		}
		
		containerView.layoutIfNeeded()
		
		switch from {
		case .Top:
			transform = CGAffineTransform(translationX: 0, y: -frame.height - UI.Margins)
		case .Bottom:
			transform = CGAffineTransform(translationX: 0, y: frame.height + UI.Margins)
		case .Center:
			transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		case .Left:
			transform = CGAffineTransform(translationX: -frame.width - UI.Margins, y: 0)
		case .Right:
			transform = CGAffineTransform(translationX: frame.width + UI.Margins, y: 0)
		}
		
		UIApplication.feedBack(style == .Success ? .Success : style == .Failure ? .Error : .On)
		
		UIView.animation(0.3, {
			
			self.alpha = 1
			self.transform = .identity
		}, {
			
			UIApplication.wait(3.0) { [weak self] in
				
				self?.dismiss(to)
			}
		})
	}
	
	public func present(in containerView:UIView, sourceView:UIView, position:Position = .Top, from:Direction = .Bottom, to:Direction = .Bottom) {
		
		containerView.addSubview(self)
		
		translatesAutoresizingMaskIntoConstraints = false
		alpha = 0
		
		switch position {
		case .Top:
			snp.makeConstraints { make in
				make.bottom.equalTo(sourceView.snp.top).offset(-UI.Margins)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Bottom:
			snp.makeConstraints { make in
				make.top.equalTo(sourceView.snp.bottom).offset(UI.Margins)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Center:
			snp.makeConstraints { make in
				make.centerY.equalTo(sourceView)
				make.left.right.equalTo(containerView).inset(UI.Margins)
			}
		case .Left:
			snp.makeConstraints { make in
				make.right.equalTo(sourceView.snp.left).offset(-UI.Margins)
				make.centerY.equalTo(sourceView)
			}
		case .Right:
			snp.makeConstraints { make in
				make.left.equalTo(sourceView.snp.right).offset(UI.Margins)
				make.centerY.equalTo(sourceView)
			}
		}
		
		containerView.layoutIfNeeded()
		
		switch from {
		case .Top:
			transform = CGAffineTransform(translationX: 0, y: -frame.height - UI.Margins)
		case .Bottom:
			transform = CGAffineTransform(translationX: 0, y: frame.height + UI.Margins)
		case .Center:
			transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		case .Left:
			transform = CGAffineTransform(translationX: -frame.width - UI.Margins, y: 0)
		case .Right:
			transform = CGAffineTransform(translationX: frame.width + UI.Margins, y: 0)
		}
		
		UIApplication.feedBack(style == .Success ? .Success : style == .Failure ? .Error : .On)
		
		UIView.animation(0.3, {
			
			self.alpha = 1
			self.transform = .identity
		}, {
			
			UIApplication.wait(3.0) { [weak self] in
				
				self?.dismiss(to)
			}
		})
	}
	
	public func dismiss(_ to:Direction) {
		
		UIView.animation(0.3, {
			
			self.alpha = 0
			
			switch to {
			case .Top:
				self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height - UI.Margins)
			case .Bottom:
				self.transform = CGAffineTransform(translationX: 0, y: self.frame.height + UI.Margins)
			case .Center:
				self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			case .Left:
				self.transform = CGAffineTransform(translationX: -self.frame.width - UI.Margins, y: 0)
			case .Right:
				self.transform = CGAffineTransform(translationX: self.frame.width + UI.Margins, y: 0)
			}
			
		}, {
			
			self.removeFromSuperview()
		})
	}
}
