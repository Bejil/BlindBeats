//
//  BB_SegmentedControl.swift
//  BlindBeats
//
//  Created by BLIN Michael on 02/10/2025.
//

import UIKit

public class BB_SegmentedControl : UISegmentedControl {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setup()
	}
	
	public override init(items: [Any]?) {
		
		super.init(items: items)
		
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		
		apportionsSegmentWidthsByContent = true
		selectedSegmentTintColor = Colors.Button.Secondary.Background
		backgroundColor = Colors.Button.Secondary.Background.withAlphaComponent(0.15)
		setTitleTextAttributes([.foregroundColor: Colors.Content.Text.withAlphaComponent(0.75), .font: Fonts.Content.Text.Regular as Any], for:.normal)
		setTitleTextAttributes([.foregroundColor: Colors.Button.Secondary.Content as Any, .font: Fonts.Content.Text.Bold as Any], for:.selected)
		snp.makeConstraints { make in
			make.height.equalTo(3 * UI.Margins)
		}
	}
}
