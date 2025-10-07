//
//  BB_Rooms_Join_Wait_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit

public class BB_Rooms_Join_Wait_ViewController : BB_ViewController {
	
	public var room:BB_Room? {
		
		didSet {
			
			if oldValue == nil {
				
				room?.observe { [weak self] room in
					
					if room == nil {
						
						self?.dismiss {
							
							let alertViewController:BB_Alert_ViewController = .init()
							alertViewController.title = String(key: "rooms.wait.canceled.title")
							alertViewController.add(String(key: "rooms.wait.canceled.content"))
							alertViewController.addDismissButton()
							alertViewController.present()
						}
					}
					else {
						
						self?.room?.promptPlayerToast(for: room)
						
						self?.room = room
						
						if self?.room?.isReady ?? false {
							
							self?.dismiss { [weak self] in
								
								let viewController:BB_Rooms_Game_Slave_ViewController = .init()
								viewController.room = self?.room
								UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
							}
						}
					}
				}
			}
			
			ownerImageView.user = room?.owner
			ownerNameLabel.text = room?.owner?.name
			playersTableView.reloadData()
			
			UIView.animation {
				
				self.playersTableView.alpha = self.room?.players.isEmpty ?? true ? 0.0 : 1.0
			}
			
			if let count = room?.players.count, count > 0 {
				
				playersTableView.scrollToRow(at: .init(row: count - 1, section: 0), at: .bottom, animated: true)
			}
		}
	}
	private lazy var ownerImageView:BB_User_ImageView = .init()
	private lazy var ownerNameLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H3
		$0.numberOfLines = 1
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var ownerStackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		$0.backgroundColor = Colors.Primary
		$0.layer.cornerRadius = UI.CornerRadius
		return $0
		
	}(UIStackView(arrangedSubviews: [ownerImageView,ownerNameLabel]))
	private lazy var playersTableView:BB_TableView = {
		
		$0.alpha = 0.0
		$0.dataSource = self
		$0.register(BB_User_TableViewCell.self, forCellReuseIdentifier: BB_User_TableViewCell.identifier)
		return $0
		
	}(BB_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: "rooms.wait.title")
		
		let stackView:UIStackView = .init(arrangedSubviews: [ownerStackView,playersTableView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func close() {
		
		room?.players.removeAll(where: { $0.uuid == BB_User.current?.uuid })
		
		BB_Alert_ViewController.presentLoading { [weak self] controller in
			
			self?.room?.save { [weak self] error in
				
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

extension BB_Rooms_Join_Wait_ViewController : UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return room?.players.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_User_TableViewCell.identifier, for: indexPath) as! BB_User_TableViewCell
		cell.user = room?.players[indexPath.row]
		return cell
	}
}
