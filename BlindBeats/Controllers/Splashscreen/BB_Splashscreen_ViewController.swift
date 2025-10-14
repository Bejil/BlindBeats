//
//  BB_Splashscreen_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 07/10/2025.
//

import UIKit

public class BB_Splashscreen_ViewController : BB_ViewController {
	
	public var completion:(()->Void?)?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalTransitionStyle = .crossDissolve
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		fetchRemoteConfig()
	}
	
	private func fetchRemoteConfig() {
		
		BB_Alert_ViewController.presentLoading { [weak self] controller in
			
			BB_Firebase.shared.prepareRemoteConfig { [weak self] error in
				
				controller?.close { [weak self] in
					
					if let error {
						
						BB_Alert_ViewController.present(error) { [weak self] in
							
							self?.fetchRemoteConfig()
						}
					}
					else {
						
						self?.dismiss {
							
							self?.completion?()
						}
					}
				}
			}
		}
	}
}
