//
//  UIImage_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit
import QuartzCore

extension UIImage {
	
	public static func qrCode(from string: String?) -> UIImage? {
		
		if let data = string?.data(using: String.Encoding.ascii), let filter = CIFilter(name: "CIQRCodeGenerator") {
			
			filter.setValue(data, forKey: "inputMessage")
			
			let scale = UIScreen.main.scale
			let transform = CGAffineTransform(scaleX: scale, y: scale)
			
			if let output = filter.outputImage?.transformed(by: transform) {
				
				let colorParameters = [
					"inputColor0": CIColor(color: Colors.Secondary),
					"inputColor1": CIColor(color: .clear)
				]
				let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)
				
				return UIImage(ciImage: colored)
			}
		}
		
		return nil
	}
}
