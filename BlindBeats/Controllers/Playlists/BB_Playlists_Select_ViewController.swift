//
//  BB_Playlists_Select_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 22/09/2025.
//

import UIKit

public class BB_Playlists_Select_ViewController : BB_Playlists_ViewController {
	
	public override var playlists: [BB_Playlist]? {
		
		didSet {
			
			navigationItem.rightBarButtonItem = nil
		}
	}
	public var selectHandler:((BB_Playlist?)->Void)?
	private lazy var segmentedControl:BB_SegmentedControl = .init(items: [String(key: "playlists.select.segmentedControl.0"), String(key: "playlists.select.segmentedControl.1")])
	private lazy var searchTextField:BB_TextField = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		$0.addAction(.init(handler: { [weak self] _ in
			
			if self?.searchTextField.text?.isEmpty ?? false {
				
				self?.updatePlaylists()
			}
			else {
				
				if self?.segmentedControl.selectedSegmentIndex == 0 {
					
					self?.tableView.showPlaceholder(.Loading)
					
					BB_Playlist.search(title: self?.searchTextField.text, { [weak self] error, playlists in
						
						self?.tableView.dismissPlaceholder()
						
						if let error {
							
							self?.tableView.showPlaceholder(.Error, error)
						}
						
						self?.playlists = playlists
					})
				}
				else {
					
					self?.tableView.showPlaceholder(.Loading)
					
					BB_Playlist.search(userName: self?.searchTextField.text, { [weak self] error, playlists in
						
						self?.tableView.dismissPlaceholder()
						
						if let error {
							
							self?.tableView.showPlaceholder(.Error, error)
						}
						
						self?.playlists = playlists
					})
				}
			}
			
		}), for: .editingChanged)
		return $0
		
	}(BB_TextField())
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		$0.setCustomSpacing(0, after: searchTextField)
		return $0
		
	}(UIStackView(arrangedSubviews: [segmentedControl,searchTextField,tableView,bannerView]))
	
	public override func loadView() {
		
		super.loadView()
		
		tableView.register(BB_Playlist_TableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: BB_Playlist_TableViewHeaderView.identifier)
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { (make) in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		segmentedControl.addAction(.init(handler: { [weak self] _ in
			
			self?.searchTextField.placeholder = String(key: self?.segmentedControl.selectedSegmentIndex == 0 ? "playlists.select.placeholder.0" : "playlists.select.placeholder.1")
			
			UIView.animation {
				
				self?.searchTextField.alpha = 1.0
				self?.searchTextField.isHidden = false
				
				self?.stackView.layoutIfNeeded()
			}
			
			self?.searchTextField.becomeFirstResponder()
			
		}), for: .valueChanged)
	}
}

extension BB_Playlists_Select_ViewController {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		
		var sections = 0
		
		if !(playlists?.notCompleted.isEmpty ?? true) {
			
			sections += 1
		}
		
		if !(playlists?.completed.isEmpty ?? true) {
			
			sections += 1
		}
		
		return sections
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == 0 && !(playlists?.notCompleted.isEmpty ?? true) {
			
			return playlists?.notCompleted.count ?? 0
		}
		else if (section == 1 && !(playlists?.completed.isEmpty ?? true)) || (section == 0 && (playlists?.notCompleted.isEmpty ?? true) && !(playlists?.completed.isEmpty ?? true)) {
			
			return playlists?.completed.count ?? 0
		}
		return 0
	}
	
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if section == 0 && !(playlists?.notCompleted.isEmpty ?? true) {
			
			let view:BB_Playlist_TableViewHeaderView = .init(reuseIdentifier: BB_Playlist_TableViewHeaderView.identifier)
			view.label.text = String(key: "playlists.select.section.0")
			return view
		}
		else if (section == 1 && !(playlists?.completed.isEmpty ?? true)) || (section == 0 && (playlists?.notCompleted.isEmpty ?? true) && !(playlists?.completed.isEmpty ?? true)) {
			
			let view:BB_Playlist_TableViewHeaderView = .init(reuseIdentifier: BB_Playlist_TableViewHeaderView.identifier)
			view.label.text = String(key: "playlists.select.section.1")
			return view
		}
		return nil
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		if section == 0 && !(playlists?.notCompleted.isEmpty ?? true) {
			
			return UITableView.automaticDimension
		}
		else if (section == 1 && !(playlists?.completed.isEmpty ?? true)) || (section == 0 && (playlists?.notCompleted.isEmpty ?? true) && !(playlists?.completed.isEmpty ?? true)) {
			
			return UITableView.automaticDimension
		}
			
		return 0.0
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Playlist_TableViewCell.identifier, for: indexPath) as! BB_Playlist_TableViewCell
		
		let playlist: BB_Playlist?
		
		if indexPath.section == 0 && !(playlists?.notCompleted.isEmpty ?? true) {
			
			playlist = playlists?.notCompleted[indexPath.row]
		}
		else if (indexPath.section == 1 && !(playlists?.completed.isEmpty ?? true)) || (indexPath.section == 0 && (playlists?.notCompleted.isEmpty ?? true) && !(playlists?.completed.isEmpty ?? true)) {
			
			playlist = playlists?.completed[indexPath.row]
		}
		else {
			
			playlist = nil
		}
		
		cell.playlist = playlist
		return cell
	}
	
	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let selectedPlaylist: BB_Playlist?
		
		if indexPath.section == 0 && !(playlists?.notCompleted.isEmpty ?? true) {
			
			selectedPlaylist = playlists?.notCompleted[indexPath.row]
		}
		else if (indexPath.section == 1 && !(playlists?.completed.isEmpty ?? true)) || (indexPath.section == 0 && (playlists?.notCompleted.isEmpty ?? true) && !(playlists?.completed.isEmpty ?? true)) {
			
			selectedPlaylist = playlists?.completed[indexPath.row]
		}
		else {
			
			selectedPlaylist = nil
		}
		
		dismiss { [weak self] in
			
			self?.selectHandler?(selectedPlaylist)
		}
	}
	
	public override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return nil
	}
	
	public override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		return nil
	}
	
	public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		return nil
	}
}
