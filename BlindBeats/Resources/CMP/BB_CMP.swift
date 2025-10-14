//
//  BB_CMP.swift
//  BlindBeats
//
//  Created by BLIN Michael on 07/10/2025.
//

import UserMessagingPlatform

public class BB_CMP {
	
	public static var shared:BB_CMP = .init()
	public var isConsentObtained:Bool {
		
		return ConsentInformation.shared.consentStatus == .obtained
	}
	
	public func present(_ completion:(()->Void)?) {
		
		let parameters = RequestParameters()
		parameters.isTaggedForUnderAgeOfConsent = false
		
		ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { _ in
			
			ConsentForm.load { form, error in
				
				if ConsentInformation.shared.consentStatus == .required {
					
					form?.present(from: UI.MainController) { _ in
							
						DispatchQueue.main.async {
							
							completion?()
						}
					}
				}
				else if ConsentInformation.shared.consentStatus == .obtained {
					
					completion?()
				}
			}
		}
	}
}
