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
		
		let backgroundView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
		$0.insertSubview(backgroundView, at: 0)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		$0.layer.cornerRadius = UI.CornerRadius
		$0.clipsToBounds = true
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		return $0
		
	}(UIStackView(arrangedSubviews: [selectedSongsLabel,selectedSongsCollectionView]))
	private lazy var selectedSongsLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .center
		return $0
		
	}(BB_Label())
	private lazy var selectedSongsCollectionViewLayout:UICollectionViewFlowLayout = {
		
		$0.scrollDirection = .horizontal
		$0.minimumInteritemSpacing = UI.Margins/2
		return $0
		
	}(UICollectionViewFlowLayout())
	private lazy var selectedSongsCollectionView: BB_CollectionView = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		$0.clipsToBounds = false
		$0.delegate = self
		$0.dataSource = self
		$0.register(BB_Song_Selected_CollectionViewCell.self, forCellWithReuseIdentifier: BB_Song_Selected_CollectionViewCell.identifier)
		$0.backgroundColor = .clear
		$0.showsHorizontalScrollIndicator = false
		$0.snp.makeConstraints { make in
			make.height.equalTo(3.5*UI.Margins)
		}
		return $0
		
	}(BB_CollectionView(frame: .zero, collectionViewLayout: selectedSongsCollectionViewLayout))
	private lazy var resultsTableView: BB_TableView = {
		
		$0.delegate = self
		$0.dataSource = self
		$0.register(BB_Song_TableViewCell.self, forCellReuseIdentifier: BB_Song_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	private lazy var saveButton:BB_Button = {
		
		$0.image = UIImage(systemName: "square.and.arrow.down")
		return $0
		
	}(BB_Button(String(key: "playlists.edit.save.button"), { [weak self] saveButton in
		
		self?.save()
	}))
	
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
		
		BB_Audio.shared.stopPreview()
	}
	
	private func updateUI() {
		
		selectedSongsLabel.text = String(key: "playlists.edit.selectedSongs") + " (\(playlist?.songs.count ?? 0)/\(Playlists.MaxSongsCount))"
		selectedSongsCollectionView.reloadData()
		
		UIView.animation {
			
			let state = self.playlist?.songs.isEmpty ?? true
			self.selectedSongsCollectionView.alpha = state ? 0.0 : 1.0
			self.selectedSongsCollectionView.isHidden = state
			//self.selectedSongsStackView.layoutIfNeeded()
			self.selectedSongsStackView.superview?.layoutIfNeeded()
		}
		
		resultsTableView.dismissPlaceholder()
		
		if searchResults?.isEmpty ?? true {
			
			resultsTableView.showPlaceholder(.Empty)
		}
		
		resultsTableView.reloadData()
	}
	
	private func toggleSongSelection(_ song: BB_Song?) {
		
		if let song {
			
			if let index = playlist?.songs.firstIndex(of: song) {
				
				BB_Audio.shared.stopPreview()
				playlist?.songs.remove(at: index)
			}
			else {
				
				if playlist?.songs.count ?? 0 < Playlists.MaxSongsCount {
					
					playlist?.songs.append(song)
					
					DispatchQueue.main.async { [weak self] in
						
						if self?.selectedSongsCollectionView.contentSize.width ?? 0.0 > self?.selectedSongsCollectionView.frame.size.width ?? 0.0 {
							
							let offsetX = (self?.selectedSongsCollectionView.contentSize.width ?? 0.0) - (self?.selectedSongsCollectionView.frame.size.width ?? 0.0)
							self?.selectedSongsCollectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
						}
					}
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
				
				BB_Alert_ViewController.presentLoading { [weak self] controller in
					
					self?.playlist?.user = BB_User.current
					self?.playlist?.save { [weak self] error in
						
						controller?.close { [weak self] in
							
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
			BB_Audio.shared.play(.button)
			
			toggleSongSelection(song)
		}
	}
}

extension BB_Playlists_Edit_ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return playlist?.songs.count ?? 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BB_Song_Selected_CollectionViewCell.identifier, for: indexPath) as! BB_Song_Selected_CollectionViewCell
		cell.song = playlist?.songs[indexPath.item]
		cell.deleteClosure = { [weak self] in
			
			UIApplication.feedBack(.Off)
			BB_Audio.shared.play(.button)
			
			self?.toggleSongSelection(self?.playlist?.songs[indexPath.item])
		}
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let layout = collectionViewLayout as! UICollectionViewFlowLayout
		let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(2.25-1))
		let width = (collectionView.frame.width - totalSpacing) / CGFloat(2.15)
		return CGSize(width: width, height: collectionView.frame.size.height)
	}
}
