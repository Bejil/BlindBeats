//
//  BB_PLaylist_Alert_Delete_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 16/09/2025.
//

import Foundation

public class BB_PLaylist_Alert_Delete_ViewController : BB_Alert_ViewController {
	
	public var playlist:BB_Playlist?
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = String(key: "playlists.delete.alert.title")
		add(String(key: "playlists.delete.alert.label"))
		
		let button = addButton(title: String(key: "alert.dismiss.button")) { [weak self] button in
			
			button?.isLoading = true
			
			self?.playlist?.delete { error in
				
				button?.isLoading = false
				
				self?.close {
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
					else {
						
						NotificationCenter.post(.updatePlaylist)
					}
				}
			}
		}
		button.type = .delete
		
		addCancelButton()
	}
	
	@MainActor required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
