//
//  BB_Playlists_Edit_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit
import StoreKit
import MusicKit

public class BB_Playlists_Edit_ViewController : BB_ViewController {
	
	public var playlist:BB_Playlist? {
		
		didSet {
			
			updateUI()
		}
	}
	private var searchResults:[BB_Song]? {
		
		didSet {
			
			updateUI()
		}
	}
	private lazy var searchTextField: BB_TextField = {
		
		$0.placeholder = String(key: "playlists.edit.textField.placeholder")
		$0.addAction(.init(handler: { [weak self] _ in
			
			self?.resultsTableView.showPlaceholder(.Loading)
			
			BB_Song.get(self?.searchTextField.text) { songs in
				
				self?.resultsTableView.dismissPlaceholder()
				
				self?.searchResults = songs
			}
			
		}), for: .editingChanged)
		$0.delegate = self
		return $0
		
	}(BB_TextField())
	private lazy var selectedSongsStackView: UIStackView = {
		
		$0.backgroundColor = Colors.Tertiary
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		$0.layer.cornerRadius = UI.CornerRadius
		$0.clipsToBounds = true
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(horizontal: UI.Margins, vertical: 3*UI.Margins/4)
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			UIApplication.feedBack(.On)
			BB_Sound.shared.playSound(.Button)
			
			let viewController:BB_Playlists_Edit_Songs_ViewController = .init()
			viewController.playlist = self?.playlist
			self?.navigationController?.pushViewController(viewController, animated: true)
			
		}))
		
		let imageView:BB_ImageView = .init(image: UIImage(systemName: "chevron.right.circle.fill"))
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = .white
		imageView.snp.makeConstraints { make in
			make.size.equalTo(1.5*UI.Margins)
		}
		$0.addArrangedSubview(imageView)
		
		return $0
		
	}(UIStackView(arrangedSubviews: [selectedSongsLabel]))
	private lazy var selectedSongsLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var resultsTableView: BB_TableView = {
		
		$0.delegate = self
		$0.dataSource = self
		$0.register(BB_Song_TableViewCell.self, forCellReuseIdentifier: BB_Song_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	private lazy var saveButton:BB_Button = .init(String(key: "playlists.edit.save.button"), { [weak self] _ in
		
		self?.save()
	})
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: playlist == nil ? "playlists.edit.create.title" : "playlists.edit.update.title")
		
		if playlist == nil {
			
			playlist = .init()
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [searchTextField,selectedSongsStackView,resultsTableView,saveButton])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		searchTextField.becomeFirstResponder()
		updateUI()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		BB_Sound.shared.stopPreview()
	}
	
	private func updateUI() {
		
		selectedSongsLabel.text = String(key: "playlists.edit.selectedSongs") + " (\(playlist?.songs.count ?? 0)/\(BB_Firebase.shared.getRemoteConfig(.PlaylistsMaxSongsCount).numberValue.intValue))"
		
		resultsTableView.dismissPlaceholder()
		
		if searchResults?.isEmpty ?? true {
			
			resultsTableView.showPlaceholder(.Empty)
		}
		
		resultsTableView.reloadData()
	}
	
	private func toggleSongSelection(_ song: BB_Song?) {
		
		if let song {
			
			if let index = playlist?.songs.firstIndex(of: song) {
				
				BB_Sound.shared.stopPreview()
				playlist?.songs.remove(at: index)
			}
			else {
				
				if playlist?.songs.count ?? 0 < BB_Firebase.shared.getRemoteConfig(.PlaylistsMaxSongsCount).numberValue.intValue {
					
					playlist?.songs.append(song)
				}
				else {
					
					BB_Alert_ViewController.present(BB_Error(String(key: "playlists.edit.max")))
				}
			}
		}
		
		updateUI()
	}
	
	private func save() {
		
		if playlist?.songs.isEmpty ?? true {
			
			BB_Alert_ViewController.present(BB_Error(String(key: "playlists.edit.empty.error")))
		}
		else {
			
			if playlist?.title?.isEmpty ?? true {
				
				let viewController:BB_Playlist_Alert_Name_ViewController = .init()
				playlist?.user = BB_User.current
				viewController.playlist = playlist
				viewController.handler = { [weak self] in
					
					self?.dismiss {
						
						NotificationCenter.post(.updatePlaylist)
					}
				}
				viewController.present()
			}
			else {
				
				saveButton.isLoading = true
				
				playlist?.user = BB_User.current
				playlist?.save { [weak self] error in
					
					self?.saveButton.isLoading = false
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
					else {
						
						self?.dismiss {
							
							NotificationCenter.post(.updatePlaylist)
						}
					}
				}
			}
		}
	}
}

extension BB_Playlists_Edit_ViewController: UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		_ = UIApplication.shared.resignFirstResponder()
		
		return true
	}
}

extension BB_Playlists_Edit_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return searchResults?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let song = searchResults?[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Song_TableViewCell.identifier, for: indexPath) as! BB_Song_TableViewCell
		cell.isEditing = true
		cell.song = song
		cell.isSelected = playlist?.songs.contains { $0.uuid == song?.uuid } ?? false
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let song = searchResults?[indexPath.row] {
			
			UIApplication.feedBack(playlist?.songs.contains(where: { $0.uuid == song.uuid }) ?? false ? .On : .Off)
			BB_Sound.shared.playSound(.Button)
			
			toggleSongSelection(song)
		}
	}
}
