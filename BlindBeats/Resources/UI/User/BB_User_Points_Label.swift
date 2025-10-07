//
//  BB_User_Points_Label.swift
//  BlindBeats
//
//  Created by BLIN Michael on 28/09/2025.
//

import UIKit

public class BB_User_Points_Label : BB_Label {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		font = Fonts.Content.Title.H4
		textColor = .white
		textAlignment = .center
		contentInsets = .init(horizontal: UI.Margins/2, vertical: UI.Margins/3)
		backgroundColor = Colors.Secondary
	}
	
	@MainActor required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		layer.cornerRadius = frame.size.height/2
	}
}
