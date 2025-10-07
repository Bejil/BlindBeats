//
//  BB_Rooms_Game_Master_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit

public class BB_Rooms_Game_Master_ViewController : BB_ViewController {
	
	public var room:BB_Room? {
		
		didSet {
			
			title = room?.playlist?.title
			playersTableView.reloadData()
			
			if oldValue == nil {
				
				room?.observe { [weak self] room in
					
					self?.room?.promptPlayerToast(for: room)
					self?.room = room
				}
			}
		}
	}
	private var currentSong:BB_Song? {
		
		didSet {
			
			UIView.animation {
				
				self.nextButton.alpha = 0.0
				self.nextButton.isHidden = true
				
				self.playButton.alpha = 1.0
			}
			
			playButton.song = currentSong
			coverImageView.url = currentSong?.coverUrl
			titleLabel.text = currentSong?.title
			artistLabel.text = currentSong?.artist
			albumLabel.text = currentSong?.album
			
			BB_Audio.shared.playPreview(for: currentSong, completion: { [weak self] in
				
				UIView.animation {
					
					self?.playButton.alpha = 0.0
					self?.loadingIndicatorView.alpha = 1.0
				}
				
				self?.room?.isPaused = true
				self?.room?.save { error in
					
					UIView.animation {
						
						self?.playButton.alpha = 1.0
						self?.loadingIndicatorView.alpha = 0.0
					}
					
					let isFinished = self?.room?.currentSongIndex ?? 0 == (self?.room?.playlist?.songs.count ?? 0) - 1
					
					UIView.animation {
						
						self?.nextButton.alpha = isFinished ? 0.0 : 1.0
						self?.nextButton.isHidden = isFinished
					}
					
					if isFinished {
						
						UIView.animation {
							
							self?.contentStackView.alpha = 0.0
							self?.contentStackView.isHidden = true
						}
						
						let viewController:BB_Tutorial_ViewController = .init()
						viewController.items = [
							
							.init(title: String(key: "Terminé"), timeInterval: 2.0, closure: {
								
								UIApplication.feedBack(.On)
								BB_Audio.shared.play(.tap)
							})
						]
						viewController.completion = { [weak self] in
							
							self?.close()
						}
						viewController.present()
					}
				}
			})
		}
	}
	private lazy var titleLabel: BB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var artistLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-1)
		$0.alpha = 0.75
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var albumLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.alpha = 0.5
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var loadingIndicatorView:UIActivityIndicatorView = {
		
		$0.alpha = 0.0
		$0.tintColor = .white.withAlphaComponent(0.5)
		$0.startAnimating()
		return $0
		
	}(UIActivityIndicatorView(style: .large))
	private lazy var coverImageView: BB_ImageView = {
		
		$0.contentMode = .scaleAspectFill
		$0.layer.cornerRadius = UI.CornerRadius/2
		$0.clipsToBounds = true
		$0.backgroundColor = .systemGray6
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			self?.playButton.pulse()
			BB_Audio.shared.play(.button)
			UIApplication.feedBack(.On)
			
			if BB_Audio.shared.isPlayingPreview(for: self?.currentSong) {
				
				BB_Audio.shared.stopPreview()
				
				UIView.animation {
					
					self?.playButton.alpha = 0.0
					self?.loadingIndicatorView.alpha = 1.0
				}
				
				self?.room?.isPaused = true
				self?.room?.save { error in
					
					UIView.animation {
						
						self?.nextButton.alpha = 1.0
						self?.nextButton.isHidden = false
						
						self?.playButton.alpha = 1.0
						self?.loadingIndicatorView.alpha = 0.0
					}
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
				}
			}
			else {
				
				UIView.animation {
					
					self?.playButton.alpha = 0.0
					self?.loadingIndicatorView.alpha = 1.0
				}
				
				self?.room?.isPaused = false
				self?.room?.save { error in
					
					UIView.animation {
						
						self?.playButton.alpha = 1.0
						self?.loadingIndicatorView.alpha = 0.0
					}
					
					if let error {
						
						BB_Alert_ViewController.present(error)
					}
					else {
						
						self?.currentSong = self?.room?.playlist?.songs[self?.room?.currentSongIndex ?? 0]
					}
				}
			}
		}))
		$0.snp.makeConstraints { make in
			make.size.equalTo(10*UI.Margins)
		}
		
		let dimBackgroundView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))
		dimBackgroundView.alpha = 0.75
		$0.addSubview(dimBackgroundView)
		dimBackgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.addSubview(playButton)
		playButton.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(2.5*UI.Margins)
		}
		
		$0.addSubview(loadingIndicatorView)
		loadingIndicatorView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(2.5*UI.Margins)
		}
		
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "music.quarternote.3")))
	private lazy var playButton:BB_Song_Play_Button = {
		
		$0.isUserInteractionEnabled = false
		$0.color = .white.withAlphaComponent(0.5)
		$0.progressColor = .white
		$0.snp.removeConstraints()
		return $0
		
	}(BB_Song_Play_Button())
	private lazy var playersTableView: BB_TableView = {
		
		$0.register(BB_User_TableViewCell.self, forCellReuseIdentifier: BB_User_TableViewCell.identifier)
		$0.dataSource = self
		return $0
		
	}(BB_TableView())
	private lazy var nextButton:BB_Button = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		return $0
		
	}(BB_Button(String(key: "Chanson suivante")) { [weak self] button in
		
		button?.isLoading = true
			
		self?.room?.isPaused = false
		self?.room?.currentSongIndex += 1
		self?.room?.save { error in
			
			button?.isLoading = false
			
			if let error {
				
				BB_Alert_ViewController.present(error)
			}
			else {
				
				self?.currentSong = self?.room?.playlist?.songs[self?.room?.currentSongIndex ?? 0]
			}
		}
	})
	private lazy var contentStackView:UIStackView = {
		
		$0.alpha = 0.0
		$0.isHidden = true
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		
		let songStackView:UIStackView = .init(arrangedSubviews: [coverImageView, titleLabel, artistLabel, albumLabel])
		songStackView.axis = .vertical
		songStackView.setCustomSpacing(1.5*UI.Margins, after: coverImageView)
		songStackView.alignment = .center
		
		$0.addArrangedSubview(songStackView)
		$0.addArrangedSubview(playersTableView)
		$0.addArrangedSubview(nextButton)
		
		return $0
		
	}(UIStackView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		view.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		let viewController:BB_Tutorial_ViewController = .init()
		viewController.items = [
			
			.init(title: String(key: "Pret ?"), timeInterval: 2.0, closure: {
				
				UIApplication.feedBack(.On)
				BB_Audio.shared.play(.button)
			}),
			.init(title: String(key: "1"), timeInterval: 1.0, closure: {
				
				UIApplication.feedBack(.On)
				BB_Audio.shared.play(.button)
			}),
			.init(title: String(key: "2"), timeInterval: 1.0, closure: {
				
				UIApplication.feedBack(.On)
				BB_Audio.shared.play(.button)
			}),
			.init(title: String(key: "3"), timeInterval: 1.0, closure: {
				
				UIApplication.feedBack(.Success)
				BB_Audio.shared.play(.tap)
			}),
			.init(title: String(key: "C'est parti !"), timeInterval: 2.0)
		]
		viewController.completion = { [weak self] in
			
			BB_Alert_ViewController.presentLoading { [weak self] controller in
				
				self?.room?.isStarted = true
				self?.room?.save { [weak self] error in
					
					if let error {
						
						controller?.close {
							
							BB_Alert_ViewController.present(error)
						}
					}
					else {
						
						controller?.close()
						
						UIView.animation {
							
							self?.contentStackView.alpha = 1.0
							self?.contentStackView.isHidden = false
						}
						
						self?.currentSong = self?.room?.playlist?.songs[self?.room?.currentSongIndex ?? 0]
					}
				}
			}
		}
		viewController.present()
	}
	
	public override func close() {
		
		BB_Alert_ViewController.presentLoading { [weak self] controller in
			
			self?.room?.delete { [weak self] error in
				
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
}

extension BB_Rooms_Game_Master_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return room?.players.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_User_TableViewCell.identifier, for: indexPath) as! BB_User_TableViewCell
		cell.user = room?.players[indexPath.row]
		return cell
	}
}
