//
//  BB_User_ImageView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit

public class BB_User_ImageView : BB_ImageView {
	
	public var user:BB_User? {
		
		didSet {
			
			if let name = user?.name, !name.isEmpty {
				
				BB_BoringAvatar.get(for: name) { [weak self] image in
					
					if let image = image {
						
						self?.image = image
					}
				}
			}
		}
	}
	
	override init() {
		
		super.init(frame: .zero)
		
		contentMode = .scaleAspectFill
		clipsToBounds = true
		layer.masksToBounds = true
		layer.borderWidth = 3
		layer.borderColor = UIColor.white.cgColor
		
		let height = 4*UI.Margins
		snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		layer.cornerRadius = height/2
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
