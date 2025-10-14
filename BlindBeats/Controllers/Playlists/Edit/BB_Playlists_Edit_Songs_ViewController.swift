//
//  BB_Playlists_Edit_Songs_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 14/10/2025.
//

import UIKit

public class BB_Playlists_Edit_Songs_ViewController : BB_ViewController {
	
	public var playlist:BB_Playlist? {
		
		didSet {
			
			updateUI()
		}
	}
	private lazy var tableView: BB_TableView = {
		
		$0.delegate = self
		$0.dataSource = self
		$0.isEditing = true
		$0.register(BB_Song_TableViewCell.self, forCellReuseIdentifier: BB_Song_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	private func updateUI() {
		
		title = String(key: "playlists.edit.songs.title") + " (\(playlist?.songs.count ?? 0)/\(BB_Firebase.shared.getRemoteConfig(.PlaylistsMaxSongsCount).numberValue.intValue))"
		
		tableView.dismissPlaceholder()
		
		if playlist?.songs.isEmpty ?? true {
			
			tableView.showPlaceholder(.Empty)
		}
		
		tableView.reloadData()
	}
}

extension BB_Playlists_Edit_Songs_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return playlist?.songs.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let song = playlist?.songs[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Song_TableViewCell.identifier, for: indexPath) as! BB_Song_TableViewCell
		cell.isEditing = false
		cell.song = song
		return cell
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		return true
	}
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete, let playlist {
			
			let alertController = BB_Alert_ViewController()
			alertController.title = String(key: "playlists.edit.songs.delete.alert.title")
			alertController.add(String(key: "playlists.edit.songs.delete.alert.contentt"))
			
			let button = alertController.addButton(title: String(key: "playlists.edit.songs.delete.alert.button")) { [weak self] _ in
				
				alertController.close()
				
				playlist.songs.remove(at: indexPath.row)
				
				self?.updateUI()
			}
			button.type = .delete
			
			alertController.addCancelButton()
			alertController.present()
		}
	}
	
	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		
		return true
	}
	
	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		if let playlist = playlist {
			
			let movedSong = playlist.songs.remove(at: sourceIndexPath.row)
			playlist.songs.insert(movedSong, at: destinationIndexPath.row)
		}
	}
}
