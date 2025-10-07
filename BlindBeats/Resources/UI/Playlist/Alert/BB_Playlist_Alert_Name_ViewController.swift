//
//  BB_Playlist_Alert_Name_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 16/09/2025.
//

import Foundation

public class BB_Playlist_Alert_Name_ViewController : BB_Alert_ViewController {
	
	public var handler:(()->Void)?
	public var playlist:BB_Playlist? {
		
		didSet {
			
			textField.text = playlist?.title
		}
	}
	private lazy var textField:BB_TextField = {
		
		$0.placeholder = String(key: "playlists.edit.title.alert.placeholder")
		$0.returnKeyType = .send
		return $0
		
	}(BB_TextField())
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "playlists.edit.title.alert.title")
		add(String(key: "playlists.edit.title.alert.label"))
		add(textField)
		
		let button = addButton(title: String(key: "playlists.edit.title.alert.button")) { [weak self] button in
			
			self?.playlist?.title = self?.textField.text ?? ""
			
			button?.isLoading = true
			
			self?.playlist?.save { [weak self] error in
				
				button?.isLoading = false
				
				self?.close {
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
					else {
						
						if let handler = self?.handler {
						
							handler()
						}
						else {
							
							NotificationCenter.post(.updatePlaylist)
						}
					}
				}
			}
		}
		button.isEnabled = false
		
		textField.addAction(.init(handler: { [weak self] _ in
			
			button.isEnabled = !(self?.textField.text?.isEmpty ?? true)
			
		}), for: .editingChanged)
		
		addCancelButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		textField.becomeFirstResponder()
	}
}
