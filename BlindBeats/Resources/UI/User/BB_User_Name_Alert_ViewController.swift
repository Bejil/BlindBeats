//
//  BB_User_Name_Alert_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/08/2025.
//

import UIKit

public class BB_User_Name_Alert_ViewController : BB_Alert_ViewController {
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		backgroundView.isUserInteractionEnabled = false
		title = String(key: "user.name.alert.title")
		
		add(String(key: "user.name.alert.label"))
		
		let textField:BB_TextField = .init()
		textField.text = BB_User.current?.name
		textField.placeholder = String(key: "user.name.alert.placeholder")
		textField.returnKeyType = .send
		add(textField)
		
		let button = addDismissButton { [weak self] button in
			
			button?.isLoading = true
				
			BB_User.checkName(textField.text) { [weak self] isAvailable, error in
				
				if let error {
					
					self?.close {
						
						let alertController = BB_Alert_ViewController.present(error)
						alertController.dismissHandler = {
							
							BB_User_Name_Alert_ViewController().present()
						}
					}
				}
				else if isAvailable {
					
					let user:BB_User = .current ?? .init()
					user.name = textField.text
					user.save { [weak self] error in
						
						NotificationCenter.post(.updateUser)
						
						self?.close {
							
							if let error {
								
								let alertController = BB_Alert_ViewController.present(error)
								alertController.dismissHandler = {
									
									BB_User_Name_Alert_ViewController().present()
								}
							}
						}
					}
				}
				else {
					
					self?.close {
						
						let alertController = BB_Alert_ViewController.present(BB_Error(String(key: "user.name.alert.error")))
						alertController.dismissHandler = {
							
							BB_User_Name_Alert_ViewController().present()
						}
					}
				}
			}
		}
		button.isEnabled = false
		button.style = .solid
		textField.addAction(.init(handler: { _ in
			
			button.isEnabled = !(textField.text?.isEmpty ?? true)
			
		}), for: .editingChanged)
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
