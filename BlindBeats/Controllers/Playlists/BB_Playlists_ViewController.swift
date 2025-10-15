//
//  BB_Playlists_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import UIKit
import StoreKit
import MusicKit
import GoogleMobileAds

public class BB_Playlists_ViewController : BB_ViewController {
	
	public var user:BB_User? {
		
		didSet {
			
			updateCreateButton()
		}
	}
	public var playlists:[BB_Playlist]? {
		
		didSet {
			
			let hasPlaylists = playlists?.isEmpty == false
			
			if user == BB_User.current {
				
				navigationItem.rightBarButtonItem = hasPlaylists ? .init(title: String(key: "playlists.edit.button"), primaryAction: .init(handler: { [weak self] _ in
					
					UIApplication.feedBack(.On)
					BB_Sound.shared.playSound(.Button)
					
					let isEditing = self?.tableView.isEditing ?? false
					self?.tableView.setEditing(!isEditing, animated: true)
					
				})) : nil
			}
			
			tableView.dismissPlaceholder()
			
			if !hasPlaylists {
				
				let placeholderView = tableView.showPlaceholder(.Empty)
				
				if user == BB_User.current {
					
					let button = placeholderView.addButton(String(key: "playlists.placeholder.button")) { _ in
						
						UI.MainController.present(BB_NavigationController(rootViewController: BB_Playlists_Edit_ViewController()), animated: true)
					}
					button.image = UIImage(systemName: "plus")
				}
			}
			
			tableView.reloadData()
			
			updateCreateButton()
		}
	}
	public lazy var tableView: BB_TableView = {
		
		$0.clipsToBounds = false
		$0.delegate = self
		$0.dataSource = self
		$0.backgroundView = .init()
		$0.separatorStyle = .none
		$0.register(BB_Playlist_TableViewCell.self, forCellReuseIdentifier: BB_Playlist_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	public lazy var bannerView = BB_Ads.shared.presentBanner(BB_Ads.Identifiers.Banner.Playlists, self)
	private lazy var createButton:BB_Button = {
		
		$0.isHidden = true
		$0.image = UIImage(systemName: "plus")
		return $0
		
	}(BB_Button(String(key: "playlists.create.button"), { _ in
		
		UI.MainController.present(BB_NavigationController(rootViewController: BB_Playlists_Edit_ViewController()), animated: true)
	}))
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		return $0
		
	}(UIStackView(arrangedSubviews: [tableView,bannerView,createButton]))
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: user == BB_User.current ? "playlists.user.title" : "playlists.title")
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		NotificationCenter.add(.updatePlaylist) { [weak self] _ in
			
			self?.updatePlaylists()
		}
		
		Task { [weak self] in
			
			let status = await MusicAuthorization.request()
			
			if status != .authorized {
				
				let alertController:BB_Alert_ViewController = .present(BB_Error(String(key: "playlists.auth.error")))
				alertController.backgroundView.isUserInteractionEnabled = false
				alertController.dismissHandler = {
					
					self?.dismiss()
				}
			}
		}
		
		updatePlaylists()
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		bannerView.refresh()
	}
	
	public func updatePlaylists() {
		
		tableView.showPlaceholder(.Loading)
		
		let completion:((Error?, [BB_Playlist]?)->Void) = { [weak self] error, playlists in
			
			self?.tableView.dismissPlaceholder()
			
			if let error {
				
				self?.tableView.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.updatePlaylists()
				}
			}
			else {
				
				self?.playlists = playlists
			}
		}
		
		if let user {
			
			user.getPlaylists(completion)
		}
		else {
			
			BB_Playlist.getPlaylists { error, playlists in
				
				completion(error,playlists?.filter({ $0.user != BB_User.current }))
			}
		}
	}
	
	private func updateCreateButton() {
		
		let hasPlaylists = playlists?.isEmpty == false
		createButton.isHidden = user != BB_User.current || (user == BB_User.current && !hasPlaylists)
	}
}

extension BB_Playlists_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return playlists?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Playlist_TableViewCell.identifier, for: indexPath) as! BB_Playlist_TableViewCell
		cell.playlist = playlists?[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if user == BB_User.current {
			
			let viewController:BB_Playlists_Edit_ViewController = .init()
			viewController.playlist = playlists?[indexPath.row]
			UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
		}
		else {
			
			BB_User.current?.startGame { [weak self] in
				
				self?.dismiss { [weak self] in
					
					let viewController:BB_Game_Solo_ViewController = .init()
					viewController.playlist = self?.playlists?[indexPath.row]
					
					let navigationController:BB_NavigationController = .init(rootViewController: viewController)
					navigationController.navigationBar.prefersLargeTitles = false
					
					UI.MainController.present(navigationController, animated: true)
				}
			}
		}
	}
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
			
			return nil
			
		}) { [weak self] (suggestedActions) -> UIMenu? in
			
			if self?.user == BB_User.current {
				
				let cell = tableView.cellForRow(at: indexPath) as? BB_Playlist_TableViewCell
				return cell?.menu
			}
			
			return nil
		}
	}
	
	public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		
		guard let indexPath = configuration.identifier as? IndexPath else { return }
		
		animator.addCompletion {
			
			tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
		}
	}
	
	public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		if user == BB_User.current {
			
			let cell = tableView.cellForRow(at: indexPath) as? BB_Playlist_TableViewCell
			return cell?.leadingSwipeActionsConfiguration
		}
		
		return nil
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		if user == BB_User.current {
			
			let cell = tableView.cellForRow(at: indexPath) as? BB_Playlist_TableViewCell
			return cell?.trailingSwipeActionsConfiguration
		}
		
		return nil
	}
}
