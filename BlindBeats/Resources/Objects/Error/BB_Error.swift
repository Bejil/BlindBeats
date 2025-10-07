//
//  BB_Error.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import Foundation

public class BB_Error : NSError, @unchecked Sendable {
	
	public convenience init(_ string:String?) {
		
		self.init(domain: Bundle.main.bundleIdentifier ?? "", code: 000, userInfo: [NSLocalizedDescriptionKey: string ?? ""])
	}
}
