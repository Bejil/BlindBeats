//
//  BB_TextField.swift
//  BlindBeats
//
//  Created by BLIN Michael on 11/09/2025.
//

import UIKit

public class BB_TextField : UITextField {
	
	public var contentInsets: UIEdgeInsets = .zero {
		
		didSet {
			
			layoutIfNeeded()
		}
	}
	
	public var isLoading: Bool = false {
		
		didSet {
			
			updateLoadingState()
		}
	}
	
	private lazy var activityIndicator: UIActivityIndicatorView = {
		
		$0.style = .medium
		$0.color = Colors.Secondary
		$0.hidesWhenStopped = true
		return $0
		
	}(UIActivityIndicatorView())
	
	public override var intrinsicContentSize: CGSize {
		
		get {
			
			var size: CGSize = super.intrinsicContentSize
			size.width += contentInsets.left + contentInsets.right
			size.height += contentInsets.top + contentInsets.bottom
			return size
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setup()
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		
		backgroundColor = .white
		layer.cornerRadius = UI.CornerRadius
		font = Fonts.Content.Text.Regular
		textColor = Colors.Content.Text
		clearButtonMode = .whileEditing
		autocorrectionType = .no
		
		// Insets par défaut
		contentInsets = UIEdgeInsets(top: UI.Margins/2, left: UI.Margins, bottom: UI.Margins/2, right: UI.Margins)
		
		snp.makeConstraints { make in
			make.height.equalTo(2.5*UI.Margins)
		}
	}
	
	public override func textRect(forBounds bounds: CGRect) -> CGRect {
		
		return bounds.inset(by: contentInsets)
	}
	
	public override func editingRect(forBounds bounds: CGRect) -> CGRect {
		
		return bounds.inset(by: contentInsets)
	}
	
	public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		
		return bounds.inset(by: contentInsets)
	}
	
	public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
		
		let clearButtonRect = super.clearButtonRect(forBounds: bounds)
		return CGRect(
			x: clearButtonRect.origin.x - contentInsets.right,
			y: clearButtonRect.origin.y,
			width: clearButtonRect.width,
			height: clearButtonRect.height
		)
	}
	
	public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		
		let rightViewRect = super.rightViewRect(forBounds: bounds)
		return CGRect(
			x: rightViewRect.origin.x - contentInsets.right,
			y: rightViewRect.origin.y,
			width: rightViewRect.width,
			height: rightViewRect.height
		)
	}
	
	public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		
		let leftViewRect = super.leftViewRect(forBounds: bounds)
		return CGRect(
			x: leftViewRect.origin.x + contentInsets.left,
			y: leftViewRect.origin.y,
			width: leftViewRect.width,
			height: leftViewRect.height
		)
	}
	
	private func updateLoadingState() {
		
		if isLoading {
			
			// Créer un conteneur pour l'activity indicator
			let containerView = UIView()
			containerView.addSubview(activityIndicator)
			
			activityIndicator.snp.makeConstraints { make in
				make.center.equalToSuperview()
				make.size.equalTo(20)
			}
			
			// Définir la taille du conteneur
			containerView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
			
			leftView = containerView
			leftViewMode = .always
			
			activityIndicator.startAnimating()
		}
		else {
			
			leftView = nil
			leftViewMode = .never
			
			activityIndicator.stopAnimating()
		}
	}
}
