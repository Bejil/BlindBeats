//
//  ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit

public class BB_Home_ViewController: BB_ViewController {

	private lazy var menuStackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 1.5*UI.Margins
		
		let titleLabel:BB_Label = .init()
		titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize + 20)
		titleLabel.textAlignment = .center
		
		let attributedString = NSMutableAttributedString()
		
		let blindText = NSAttributedString(string: String(key: "menu.title.0"), attributes: [
			.foregroundColor: Colors.Primary
		])
		let beatsText = NSAttributedString(string: String(key: "menu.title.1"), attributes: [
			.foregroundColor: Colors.Secondary
		])
		
		attributedString.append(blindText)
		attributedString.append(beatsText)
	
		titleLabel.attributedText = attributedString
		$0.addArrangedSubview(titleLabel)
		
		let baselineLabel:BB_Label = .init(String(key: "menu.subtitle"))
		baselineLabel.textAlignment = .center
		$0.addArrangedSubview(baselineLabel)
		$0.setCustomSpacing(1.5*$0.spacing, after: baselineLabel)
		
		let playlistsButton: BB_Button = .init(String(key: "menu.playlists.button"), { _ in
			
			let viewController:BB_Playlists_ViewController = .init()
			viewController.user = BB_User.current
			UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
		})
		playlistsButton.image = UIImage(systemName: "music.note.list")
		$0.addArrangedSubview(playlistsButton)
		
//		let createBlindTestButton: BB_Button = .init(String(key: "menu.rooms.button"), { _ in
//			
//			let viewController:BB_Rooms_Create_ViewController = .init()
//			UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
//		})
//		createBlindTestButton.type = .secondary
//		createBlindTestButton.image = UIImage(systemName: "plus.circle")
//		
//		let joinBlindTestButton: BB_Button = .init(nil, { _ in
//			
//			let viewController:BB_Rooms_Join_Scan_ViewController = .init()
//			viewController.handler = { roomId in
//
//				BB_Alert_ViewController.presentLoading { controller in
//					
//					BB_Room.get(roomId) { error, room in
//						
//						if let error {
//							
//							controller?.close {
//								
//								BB_Alert_ViewController.present(error)
//							}
//						}
//						else if let room, let user = BB_User.current {
//							
//							room.players.append(user)
//							room.save { error in
//								
//								controller?.close {
//									
//									if let error {
//										
//										BB_Alert_ViewController.present(error)
//									}
//									else {
//										
//										let viewController:BB_Rooms_Join_Wait_ViewController = .init()
//										viewController.room = room
//										UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
//									}
//								}
//							}
//						}
//					}
//				}
//			}
//			UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
//		})
//		joinBlindTestButton.type = .secondary
//		joinBlindTestButton.style = .tinted
//		joinBlindTestButton.image = UIImage(systemName: "qrcode.viewfinder")
//		joinBlindTestButton.snp.makeConstraints { make in
//			
//			make.width.equalTo(joinBlindTestButton.snp.height)
//		}
//		
//		let blindTestStackView:UIStackView = .init(arrangedSubviews: [createBlindTestButton,joinBlindTestButton])
//		blindTestStackView.axis = .horizontal
//		blindTestStackView.spacing = UI.Margins
//		blindTestStackView.alignment = .center
//		$0.addArrangedSubview(blindTestStackView)
		
		let soloButton: BB_Button = .init(String(key: "menu.solo.button"), { [weak self] _ in
			
			if BB_User.current?.diamonds ?? 0 < BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue {
				
				let alertController:BB_Alert_ViewController = .init()
				alertController.title = String(key: "menu.solo.alert.title")
				alertController.add(String(key: "menu.solo.alert.error.0") + String(key: "user.diamonds") + String(key: "menu.solo.alert.error.1"))
				alertController.addButton(title: String(key: "menu.solo.alert.button")) { _ in
					
					alertController.close {
						
						UI.MainController.present(BB_NavigationController(rootViewController: BB_Shop_ViewController()), animated: true)
					}
				}
				alertController.addDismissButton()
				alertController.present()
				BB_Alert_ViewController.present(BB_Error(String(key: "menu.solo.alert.error.0") + String(key: "user.diamonds") + String(key: "menu.solo.alert.error.1")))
			}
			else {
				
				let alertController:BB_Alert_ViewController = .init()
				alertController.title = String(key: "menu.solo.alert.title")
				alertController.add(String(key: "menu.solo.alert.content"))
				let button = alertController.addButton(title: String(key: "menu.solo.alert.button.title")) { [weak self] _ in
					
					alertController.close { [weak self] in
						
						let viewController:BB_Playlists_Select_ViewController = .init()
						viewController.selectHandler = { [weak self] playlist in
							
							let viewController:BB_Game_Solo_ViewController = .init()
							viewController.playlist = playlist
							
							let navigationController:BB_NavigationController = .init(rootViewController: viewController)
							navigationController.navigationBar.prefersLargeTitles = false
							
							UI.MainController.present(navigationController, animated: true)
						}
						UI.MainController.present(BB_NavigationController(rootViewController: viewController), animated: true)
					}
				}
				button.subtitle = [String(key: "menu.solo.alert.button.subtitle"),"\(BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue)",String(key: "user.diamonds")].joined(separator: " ")
				alertController.addCancelButton()
				alertController.present()
			}
		})
		soloButton.image = UIImage(systemName: "microphone.fill")
		soloButton.type = .secondary
		$0.addArrangedSubview(soloButton)
		
		return $0
		
	}(UIStackView())
	
	override public func loadView() {
		
		super.loadView()
		
		navigationItem.leftBarButtonItem = .init(title: String(key: "menu.shop"), primaryAction: .init(handler: { _ in
			
			UI.MainController.present(BB_NavigationController(rootViewController: BB_Shop_ViewController()), animated: true)
		}))
		
		let scrollView:BB_ScrollView = .init()
		scrollView.clipsToBounds = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.isCentered = true
		scrollView.addSubview(menuStackView)
		menuStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview().inset(UI.Margins/5)
		}
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [scrollView])
		contentStackView.spacing = UI.Margins
		contentStackView.axis = .vertical
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(horizontal: 3*UI.Margins)
		
		let stackView:UIStackView = .init(arrangedSubviews: [contentStackView,BB_User_StackView()])
		stackView.spacing = 2*UI.Margins
		stackView.axis = .vertical
		
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalTo(view.safeAreaLayoutGuide)
			make.top.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
			make.bottom.equalToSuperview()
		}
		
		menuStackView.animate()
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
	}
}

