//
//  BB_ImageView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 11/09/2025.
//

import UIKit
import Alamofire
import AlamofireImage

public class BB_ImageView : UIImageView {
	
	public var url:String? {
		
		didSet {
			
			if let url = url {
				
				AF.request(url).validate().responseImage { [weak self] (response) in
					
					DispatchQueue.main.async { [weak self] in
						
						if case .success(let image) = response.result {
							
							self?.image = image
						}
					}
				}
			}
		}
	}
	
	init() {
		
		super.init(frame: .zero)
		
		setup()
	}
	
	public override init(frame: CGRect) {
	
		super.init(frame: frame)
		
		setup()
	}
	
	public override init(image: UIImage?) {
		
		super.init(image: image)
		
		setup()
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		
		isUserInteractionEnabled = true
		tintColor = .white
	}
}
