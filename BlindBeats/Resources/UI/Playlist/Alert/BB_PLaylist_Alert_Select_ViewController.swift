//
//  BB_PLaylist_Alert_Select_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 18/09/2025.
//

import UIKit

public class BB_PLaylist_Alert_Select_ViewController : BB_Alert_ViewController {
	
//	public var closure:((BB_User.Playlist?)->Void)?
//	private lazy var tableView: BB_TableView = {
//		
//		$0.isHeightDynamic = true
//		$0.clipsToBounds = false
//		$0.delegate = self
//		$0.dataSource = self
//		$0.backgroundView = .init()
//		$0.separatorStyle = .none
//		$0.register(BB_Playlist_TableViewCell.self, forCellReuseIdentifier: BB_Playlist_TableViewCell.identifier)
//		return $0
//		
//	}(BB_TableView())
//	
//	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//		
//		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//		
//		title = String(key: "Sélectionnez une playlist")
//		add(String(key: "Choisissez une playlist parmi celles que vous avez créées"))
//		add(tableView)
//		addButton(sticky: true, title: String(key: "Créer une playlist")) { [weak self] _ in
//			
//			self?.close {
//				
//				UI.MainController.present(BB_NavigationController(rootViewController: BB_Playlists_ViewController()), animated: true)
//			}
//		}
//		let button = addButton(sticky: true, title: String(key: "Annuler")) { [weak self] _ in
//			
//			self?.close()
//		}
//		button.style = .transparent
//		button.type = .navigation
//	}
//	
//	@MainActor required public init?(coder: NSCoder) {
//		
//		fatalError("init(coder:) has not been implemented")
//	}
//}
//
//// MARK: - UITableViewDataSource
//extension BB_PLaylist_Alert_Select_ViewController: UITableViewDataSource, UITableViewDelegate {
//	
//	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		
//		let playlists:[BB_User.Playlist]? = BB_User.current?.playlists
//		return playlists?.count ?? 0
//	}
//	
//	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		
//		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Playlist_TableViewCell.identifier, for: indexPath) as! BB_Playlist_TableViewCell
//		let playlists:[BB_User.Playlist]? = BB_User.current?.playlists
//		cell.playlist = playlists?[indexPath.row]
//		return cell
//	}
//	
//	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		
//		tableView.deselectRow(at: indexPath, animated: true)
//		
//		closure?(BB_User.current?.playlists?[indexPath.row])
//		close()
//	}
}
