//
//  BB_Rooms_Game_Slave_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit

public class BB_Rooms_Game_Slave_ViewController : BB_ViewController {
	
	public var room:BB_Room? {
		
		didSet {
			
			if oldValue == nil {
				
				room?.observe { [weak self] room in
					
					if room == nil {
						
						self?.dismiss {
							
							let alertViewController:BB_Alert_ViewController = .init()
							alertViewController.title = String(key: "rooms.game.slave.canceled.title")
							alertViewController.add(String(key: "rooms.game.slave.canceled.content"))
							alertViewController.addDismissButton()
							alertViewController.present()
						}
					}
					else {
						
						self?.room?.promptPlayerToast(for: room)
						self?.room = room
						
						if room?.isStarted ?? false {
							
							let isPaused = room?.isPaused ?? false
							
							if isPaused {
								
								BB_Audio.shared.stopPreview()
							}
							else {
								
								BB_Audio.shared.playPreview(for: self?.room?.playlist?.songs[self?.room?.currentSongIndex ?? 0])
							}
							
							UIView.animation {
								
								self?.waveFormContainerView.alpha = isPaused ? 0.0 : 1.0
								self?.waveFormContainerView.isHidden = isPaused
							}
							
							if isPaused {
								
								self?.guessTextField.resignFirstResponder()
							}
							else {
								
								self?.guessTextField.becomeFirstResponder()
							}
						}
					}
				}
			}
		}
	}
	private lazy var waveFormContainerView:UIView = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(10*UI.Margins)
		}
		
		let waveFormView:BB_Waveform_View = .init()
		$0.addSubview(waveFormView)
		waveFormView.snp.makeConstraints { make in
			make.top.bottom.centerX.equalToSuperview()
			make.size.width.equalToSuperview().inset(UI.Margins)
		}
		return $0
		
	}(UIView())
	private lazy var guessStackView:UIStackView = {
		
		let height = 3.5*UI.Margins
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		$0.isLayoutMarginsRelativeArrangement = true
		$0.backgroundColor = Colors.Primary
		$0.layoutMargins = .init(UI.Margins)
		$0.addArrangedSubview(guessTextField)
		
		let button:BB_Button = .init(nil, { [weak self] _ in
			
			self?.compare()
		})
		button.type = .secondary
		button.image = UIImage(systemName: "arrowtriangle.right.fill")
		button.snp.remakeConstraints { make in
			make.size.equalTo(height)
		}
		button.configuration?.background.cornerRadius = height/2.5
		button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		$0.addArrangedSubview(button)
		
		guessTextField.snp.remakeConstraints { make in
			make.height.equalTo(height)
		}
		
		return $0
		
	}(UIStackView())
	private lazy var guessTextField:BB_TextField = {
		
		$0.setContentHuggingPriority(.defaultLow, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		$0.placeholder = String(key: "Votre proposition")
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BB_TextField())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = "Slave"
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [waveFormContainerView])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins
		contentStackView.backgroundColor = .red
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		
		let containerStackView:UIStackView = .init(arrangedSubviews: [contentStackView,guessStackView])
		containerStackView.axis = .vertical
		containerStackView.spacing = UI.Margins
		view.addSubview(containerStackView)
		containerStackView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
			make.left.right.bottom.equalToSuperview()
		}
		
		NotificationCenter.add(UIResponder.keyboardWillShowNotification) { [weak self] notification in
			
			if let self {
				
				let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0.0
				
				containerStackView.snp.remakeConstraints { make in
					make.top.equalTo(self.view.safeAreaLayoutGuide).inset(UI.Margins)
					make.left.right.equalToSuperview()
					make.bottom.equalToSuperview().inset(height)
				}
				
				self.view.layoutIfNeeded()
			}
		}
		
		NotificationCenter.add(UIResponder.keyboardWillHideNotification) { [weak self] _ in
			
			if let self {
				
				containerStackView.snp.remakeConstraints { make in
					make.top.equalTo(self.view.safeAreaLayoutGuide).inset(UI.Margins)
					make.left.right.bottom.equalToSuperview()
				}
				
				self.view.layoutIfNeeded()
			}
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
						
						BB_Audio.shared.stopPreview()
						
						self?.dismiss()
					}
				}
			}
		}
	}
	
	private func compare() {
		
		
	}
}

extension BB_Rooms_Game_Slave_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return room?.players.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_User_TableViewCell.identifier, for: indexPath) as! BB_User_TableViewCell
		cell.user = room?.players[indexPath.row]
		return cell
	}
}
