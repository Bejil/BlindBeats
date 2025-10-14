//
//  BB_ProgressView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 30/09/2025.
//

import UIKit

public class BB_ProgressView : UIProgressView {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		progressViewStyle = .bar
		progressTintColor = Colors.Tertiary
		trackTintColor = .white.withAlphaComponent(0.5)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.height / 2
	}
}
