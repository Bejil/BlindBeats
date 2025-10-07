//
//  BB_Rooms_Create_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 22/09/2025.
//

import UIKit

public class BB_Rooms_Create_ViewController : BB_ViewController {
	
	private lazy var room:BB_Room = .init() {
		
		didSet {
			
			playlistButton.subtitle = room.playlist?.title
			playersTableView.reloadData()
			
			let isEmpty = room.players.isEmpty
			
			UIView.animation {
				
				self.playersPlaceholderView.alpha = isEmpty ? 1.0 : 0.0
				
				self.playersTableView.alpha = isEmpty ? 0.0 : 1.0
				
				self.startButton.alpha = isEmpty ? 0.0 : 1.0
				self.startButton.isHidden = isEmpty
				
				self.contentStackView.layoutIfNeeded()
			}
			
			if room.players.count > 0 {
				
				playersTableView.scrollToRow(at: .init(row: room.players.count - 1, section: 0), at: .bottom, animated: true)
			}
		}
	}
	private lazy var playlistButton:BB_Button = .init(String(key: "rooms.create.playlist.button")) { [weak self] _ in
		
		let viewController:BB_Playlists_Select_ViewController = .init()
		viewController.user = BB_User.current
		viewController.selectHandler = { [weak self] playlist in
			
			self?.playlistButton.subtitle = playlist?.title
			self?.room.playlist = playlist
			
			BB_Alert_ViewController.presentLoading { [weak self] controller in
				
				self?.room.save { [weak self] error in
					
					controller?.close { [weak self] in
						
						if let error {
							
							BB_Alert_ViewController.present(error)
						}
						else {
							
							if let image = UIImage.qrCode(from: self?.room.uuid) {
								
								self?.qrcodeImageiew.image = image
								
								UIView.animation {
									
									self?.qrcodeView.alpha = 1.0
									self?.qrcodeView.isHidden = false
									self?.qrcodeImageiew.superview?.layoutIfNeeded()
								}
								
								let tutorialController:BB_Tutorial_ViewController = .init()
								tutorialController.items = [
									.init(sourceView: self?.qrcodeImageiew.superview, title: String(key: "rooms.create.tutorial.0.title"), subtitle: String(key: "rooms.create.tutorial.0.subtitle"), button: String(key: "rooms.create.tutorial.0.button"))
								]
								tutorialController.key = .tutorialRoomQrcode
								tutorialController.present()
							}
						}
					}
				}
			}
		}
		UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
	}
	private lazy var qrcodeView:UIView = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		
		let view:UIView = .init()
		view.backgroundColor = .white
		view.layer.cornerRadius = UI.CornerRadius
		view.clipsToBounds = true
		$0.addSubview(view)
		view.snp.makeConstraints { make in
			make.size.equalTo(10*UI.Margins)
			make.top.bottom.centerX.equalToSuperview()
		}
		
		view.addSubview(qrcodeImageiew)
		qrcodeImageiew.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		return $0
		
	}(UIView())
	private lazy var qrcodeImageiew:BB_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		return $0
		
	}(BB_ImageView())
	private lazy var playersPlaceholderView:BB_Placeholder_View = {
		
		$0.alpha = 0.0
		return $0
		
	}(BB_Placeholder_View(.Empty))
	private lazy var playersTableView:BB_TableView = {
		
		$0.alpha = 0.0
		$0.dataSource = self
		$0.register(BB_User_TableViewCell.self, forCellReuseIdentifier: BB_User_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	private lazy var startButton:BB_Button = {
	
		$0.alpha = 0.0
		$0.isHidden = true
		return $0
		
	}(BB_Button(String(key: "rooms.create.start.button")) { [weak self] button in
		
		self?.room.isReady = true
		
		button?.isLoading = true
		
		self?.room.save { [weak self] error in
			
			button?.isLoading = false
			
			if let error {
				
				BB_Alert_ViewController.present(error)
			}
			else {
				
				self?.dismiss { [weak self] in
					
					let viewController:BB_Rooms_Game_Master_ViewController = .init()
					viewController.room = self?.room
					UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
				}
			}
		}
	})
	private lazy var contentStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		return $0
		
	}(UIStackView(arrangedSubviews: [playlistButton,qrcodeView,playersPlaceholderView,playersTableView,startButton]))
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "rooms.create.title")
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		room.observe { [weak self] room in
			
			if let room {
				
				self?.room.promptPlayerToast(for: room)
				self?.room = room
			}
		}
	}
	
	public override func close() {
		
		BB_Alert_ViewController.presentLoading { [weak self] controller in
			
			self?.room.delete { [weak self] error in
				
				controller?.close { [weak self] in
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
					else {
						
						self?.dismiss()
					}
				}
			}
		}
	}
}

extension BB_Rooms_Create_ViewController : UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return room.players.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_User_TableViewCell.identifier, for: indexPath) as! BB_User_TableViewCell
		cell.user = room.players[indexPath.row]
		return cell
	}
}


