//
//  BB_Game_Solo_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 26/09/2025.
//

import SnapKit
import UIKit

public class BB_Game_Solo_ViewController : BB_ViewController {
	
	public var playlist:BB_Playlist?
	private var guess:BB_Song.Guess = .init() {
		
		didSet {
			
			songStackView.coverImageView.addBlur()
			songStackView.artistLabel.addBlur()
			songStackView.titleLabel.addBlur()
		}
	}
	private var currentPoints:Int = 0
	private var totalPoints:Int = 0 {
		
		didSet {
			
			pointsLabel.text = "\(totalPoints)" + String(key: "game.solo.points.count")
			pointsLabel.sizeToFit()
			pointsLabel.layoutSubviews()
			pointsLabel.layoutIfNeeded()
			
			updateHelpButton()
		}
	}
	private lazy var pointsLabel:BB_User_Points_Label = {
		
		$0.numberOfLines = 1
		$0.font = Fonts.Content.Title.H4.withSize(Fonts.Content.Title.H4.pointSize-4)
		return $0
		
	}(BB_User_Points_Label("\(totalPoints)" + String(key: "game.solo.points.count")))
	private var currentSongIndex:Int = 0
	private lazy var songStackView:BB_Song_StackView = {
		
		$0.alpha = 0.0
		$0.titleLabel.layer.cornerRadius = $0.titleLabel.font.pointSize/2
		$0.artistLabel.layer.cornerRadius = $0.artistLabel.font.pointSize/2
		$0.coverView.addSubview(waveFormView)
		waveFormView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		return $0
		
	}(BB_Song_StackView())
	private lazy var waveFormView:BB_Waveform_View = .init()
	private lazy var guessView:UIView = { view in
		
		view.layer.addSublayer(guessBackgroundShapeLayer)
		view.alpha = 0.0
		view.isHidden = true
		
		view.addSubview(guessStackView)
		guessStackView.snp.makeConstraints { make in
			
			make.top.equalTo(view.safeAreaLayoutGuide).inset(1.5*UI.Margins)
			make.right.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
			guessStackViewBottomInsets = make.bottom.equalToSuperview().inset(UI.Margins).constraint
		}
		
		return view
		
	}(UIView())
	private lazy var guessBackgroundShapeLayer:CAShapeLayer = {
		
		$0.fillColor = Colors.Primary.cgColor
		return $0
		
	}(CAShapeLayer())
	private lazy var guessStackView:UIStackView = {
		
		let height = 3.5*UI.Margins
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		$0.snp.makeConstraints { make in
			make.height.equalTo(height)
		}
		
		$0.addArrangedSubview(guessTextField)
		guessTextField.snp.makeConstraints { make in
			make.height.equalToSuperview()
		}
		
		let submitButton:BB_Button = .init(nil, { [weak self] _ in
			
			self?.compare(self?.guessTextField.text)
		})
		submitButton.type = .secondary
		submitButton.image = UIImage(systemName: "arrowtriangle.right.fill")
		submitButton.snp.remakeConstraints { make in
			make.size.equalTo(height)
		}
		submitButton.configuration?.background.cornerRadius = height/2.5
		submitButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		submitButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		$0.addArrangedSubview(submitButton)
		
		return $0
		
	}(UIStackView())
	private var guessStackViewBottomInsets: Constraint?
	private lazy var guessTextField:BB_TextField = {
		
		$0.delegate = self
		$0.setContentHuggingPriority(.defaultLow, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		$0.placeholder = String(key: "game.solo.guess.placeholder")
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(BB_TextField())
	private var helpImageViewTimer:Timer?
	private lazy var helpImageView:BB_ImageView = {
		
		$0.alpha = 0.0
		$0.contentMode = .scaleAspectFit
		$0.tintColor = Colors.Tertiary
		$0.snp.makeConstraints { make in
			make.size.equalTo(4*UI.Margins)
		}
		$0.backgroundColor = .white
		$0.layer.cornerRadius = (4*UI.Margins)/2
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			BB_Sound.shared.pausePreview()
			
			let alertController:BB_Alert_ViewController = .init()
			alertController.title = String(key: "game.solo.help.alert.title")
			alertController.add(String(key: "game.solo.help.alert.content") + "\(BB_Firebase.shared.getRemoteConfig(.PointsHelp).numberValue.intValue)" + String(key: "game.solo.points.count"))
			
			if self?.guess.artist?.diagnosis != .perfect {
				
				let button = alertController.addDismissButton() { [weak self] _ in
					
					BB_Sound.shared.resumePreview()
					
					self?.currentPoints -= BB_Firebase.shared.getRemoteConfig(.PointsHelp).numberValue.intValue
					self?.totalPoints -= BB_Firebase.shared.getRemoteConfig(.PointsHelp).numberValue.intValue
					self?.updateHelpButton()
					
					self?.guess.artist = .init()
					self?.guess.artist?.score = 1.0
					self?.songStackView.artistLabel.removeBlur()
					
					if self?.guess.artist?.diagnosis == .perfect && self?.guess.title?.diagnosis == .perfect {
						
						self?.stop()
					}
				}
				button.title = String(key: "game.solo.help.alert.artist")
			}
			
			if self?.guess.title?.diagnosis != .perfect {
				
				let button = alertController.addDismissButton() { [weak self] _ in
					
					BB_Sound.shared.resumePreview()
					
					self?.currentPoints -= BB_Firebase.shared.getRemoteConfig(.PointsHelp).numberValue.intValue
					self?.totalPoints -= BB_Firebase.shared.getRemoteConfig(.PointsHelp).numberValue.intValue
					self?.updateHelpButton()
					
					self?.guess.title = .init()
					self?.guess.title?.score = 1.0
					self?.songStackView.titleLabel.removeBlur()
					
					if self?.guess.artist?.diagnosis == .perfect && self?.guess.title?.diagnosis == .perfect {
						
						self?.stop()
					}
				}
				button.title = String(key: "game.solo.help.alert.title")
			}
			
			alertController.addCancelButton()
			alertController.present()
		}))
		
		helpImageViewTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] _ in
			
			self?.helpImageView.pulse(Colors.Tertiary)
			self?.helpImageView.jiggle()
		})
		
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "lightbulb.circle.fill")))
	private var isStoppped:Bool = false
	private lazy var speechLabel:BB_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textAlignment = .center
		return $0
		
	}(BB_Label())
	private lazy var speechView:UIVisualEffectView = {
		
		$0.isUserInteractionEnabled = false
		$0.alpha = 0.0
		$0.contentView.addSubview(speechLabel)
		speechLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		return $0
		
	}(UIVisualEffectView(effect: UIBlurEffect(style: .regular)))
	
	deinit {
		
		helpImageViewTimer?.invalidate()
		helpImageViewTimer = nil
	}
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.rightBarButtonItem = .init(customView: pointsLabel)
		navigationItem.leftBarButtonItem?.isHidden = true
		navigationItem.rightBarButtonItem?.isHidden = true
		
		let songContainerStackView:UIStackView = .init(arrangedSubviews: [songStackView])
		songContainerStackView.axis = .horizontal
		songContainerStackView.alignment = .center
		songContainerStackView.isLayoutMarginsRelativeArrangement = true
		songContainerStackView.layoutMargins = .init(horizontal: UI.Margins)
		
		let containerStackView:UIStackView = .init(arrangedSubviews: [songContainerStackView,guessView])
		containerStackView.axis = .vertical
		containerStackView.spacing = UI.Margins
		view.addSubview(containerStackView)
		containerStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		view.addSubview(helpImageView)
		helpImageView.snp.makeConstraints { make in
			make.left.equalToSuperview().inset(1.25*UI.Margins)
			make.bottom.equalTo(guessView.snp.top).inset(-UI.Margins)
		}
		
		view.addSubview(speechView)
		speechView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
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
				
				UIView.animation {
					
					self.songStackView.coverView.snp.remakeConstraints { make in
						make.size.equalTo(10*UI.Margins)
					}
					self.songStackView.titleLabel.font = Fonts.Content.Title.H1
					self.songStackView.artistLabel.font = Fonts.Content.Text.Bold
					
					self.guessStackViewBottomInsets?.update(inset: UI.Margins)
					
					self.view.layoutIfNeeded()
				}
			}
		}
		
		NotificationCenter.add(UIResponder.keyboardWillHideNotification) { [weak self] _ in
			
			if let self {
				
				containerStackView.snp.remakeConstraints { make in
					make.top.equalTo(self.view.safeAreaLayoutGuide).inset(UI.Margins)
					make.left.right.bottom.equalToSuperview()
				}
				
				self.view.layoutIfNeeded()
				
				UIView.animation {
					
					self.songStackView.coverView.snp.remakeConstraints { make in
						make.size.equalTo(15*UI.Margins)
					}
					self.songStackView.titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Content.Title.H1.pointSize*1.5)
					self.songStackView.artistLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Content.Text.Bold.pointSize*1.5)
					
					self.guessStackViewBottomInsets?.update(inset: self.view.safeAreaInsets.bottom + UI.Margins)
					
					self.view.layoutIfNeeded()
				}
			}
		}
		
		BB_Speech.shared.request { [weak self] state in
			
			self?.start()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		BB_Sound.shared.stopMusic()
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: .init(x: 0, y: UI.Margins/2))
		bezierPath.addLine(to: .init(x: guessView.frame.size.width, y: 0))
		bezierPath.addLine(to: .init(x: guessView.frame.size.width, y: guessView.frame.size.height))
		bezierPath.addLine(to: .init(x: 0, y: guessView.frame.size.height))
		bezierPath.close()
		guessBackgroundShapeLayer.path = bezierPath.cgPath
	}
	
	private func start() {
		
		currentPoints = 0
		
		guess = .init()
		guessTextField.text = nil
		
		isStoppped = false
		
		var items:[BB_Tutorial_ViewController.Item] = .init()
		
		if currentSongIndex == 0 {
			
			items = [
				
				.init(title: String(key: "game.solo.tutorial.0"), timeInterval: 2.0, closure: {
					
					UIApplication.feedBack(.On)
					BB_Sound.shared.playSound(.Button)
				}),
				.init(title: String(key: "game.solo.tutorial.1"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.On)
					BB_Sound.shared.playSound(.Button)
				}),
				.init(title: String(key: "game.solo.tutorial.2"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.On)
					BB_Sound.shared.playSound(.Button)
				}),
				.init(title: String(key: "game.solo.tutorial.3"), timeInterval: 1.0, closure: {
					
					UIApplication.feedBack(.Success)
					BB_Sound.shared.playSound(.Tap)
				})
			]
		}
		
		items.append(.init(title: String(key: "game.solo.tutorial.4"), timeInterval: 2.0))
		
		let closure:(()->Void) = {
			
			let viewController:BB_Tutorial_ViewController = .init()
			viewController.items = items
			viewController.completion = { [weak self] in
				
				UIView.animation(0.3, {
					
					self?.navigationItem.leftBarButtonItem?.isHidden = false
					self?.navigationItem.rightBarButtonItem?.isHidden = false
					self?.title = String(key: "game.solo.title") + "\((self?.currentSongIndex ?? 0)+1)/\(self?.playlist?.songs.count ?? 0)"
					
					self?.songStackView.alpha = 1.0
					self?.waveFormView.alpha = 1.0
					
					self?.guessView.alpha = 1.0
					self?.guessView.isHidden = false
					
					self?.view.layoutIfNeeded()
				}, {
					
					self?.updateHelpButton()
				})
				
				self?.songStackView.animate()
				
				let currentSong = self?.playlist?.songs[self?.currentSongIndex ?? 0]
				
				self?.songStackView.song = currentSong
				
				BB_Sound.shared.playPreview(currentSong) { [weak self] in
					
					self?.stop()
				}
				
				self?.guessTextField.becomeFirstResponder()
				
				BB_Speech.shared.recognize { [weak self] string in
					
					self?.speechLabel.transform = .init(translationX: 0, y: 3*UI.Margins)
					self?.speechLabel.text = string
					
					UIView.animation(0.3, {
						
						self?.speechView.alpha = 1.0
						self?.speechLabel.transform = .identity
					}, {
						
						UIApplication.wait(0.1) { [weak self] in
							
							UIView.animation(0.3, {
								
								self?.speechView.alpha = 0.0
								self?.speechLabel.transform = .init(translationX: 0, y: -3*UI.Margins)
								
							}, {
								
								self?.speechLabel.transform = .identity
							})
						}
					})
					
					self?.compare(string)
				}
			}
			viewController.present()
		}
		
		if currentSongIndex == 0 {
			
			BB_Alert_ViewController.presentLoading { [weak self] controller in
				
				let user:BB_User = .current ?? .init()
				user.attemps += 1
				user.diamonds -= BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue
				user.lastGameDate = Date()
				user.save { error in
					
					if let error {
						
						controller?.close {
							
							BB_Alert_ViewController.present(error)
						}
					}
					else {
						
						self?.playlist?.attemps += 1
						self?.playlist?.save { error in
							
							controller?.close {
								
								if let error {
									
									BB_Alert_ViewController.present(error)
								}
								
								BB_Ads.shared.presentInterstitial(BB_Ads.Identifiers.FullScreen.Game.Solo.Start, nil) {
									
									closure()
								}
							}
						}
					}
				}
			}
		}
		else {
			
			closure()
		}
	}
	
	private func stop() {
		
		if !isStoppped {
			
			isStoppped = true
			
			BB_Speech.shared.stop()
			
			BB_Sound.shared.stopPreview()
			
			songStackView.coverImageView.removeBlur()
			songStackView.artistLabel.removeBlur()
			songStackView.titleLabel.removeBlur()
			
			UIView.animation {
				
				self.waveFormView.alpha = 0.0
				
				self.guessView.alpha = 0.0
				self.guessView.isHidden = true
				
				self.view.layoutIfNeeded()
			}
			
			if guess.diagnosis == .perfect {
				
				UIApplication.feedBack(.Success)
				BB_Sound.shared.playSound(.Success)
				
				BB_Confettis.start()
			}
			else {
				
				UIApplication.feedBack(.Error)
				BB_Sound.shared.playSound(.Error)
			}
			
			UIApplication.wait(2.0) { [weak self] in
				
				UIView.animation {
					
					self?.navigationItem.leftBarButtonItem?.isHidden = true
					self?.navigationItem.rightBarButtonItem?.isHidden = true
					self?.title = nil
					
					self?.songStackView.alpha = 0.0
				}
				
				let isLastSong = self?.currentSongIndex ?? 0 == (self?.playlist?.songs.count ?? 0) - 1
				
				let alertController:BB_Alert_ViewController = .init()
				alertController.backgroundView.isUserInteractionEnabled = false
				alertController.dismissHandler = {
					
					BB_Confettis.stop()
				}
				
				let stackView:BB_Song_StackView = .init()
				stackView.song = self?.playlist?.songs[self?.currentSongIndex ?? 0]
				stackView.titleLabel.textColor = .white
				stackView.artistLabel.textColor = .white.withAlphaComponent(0.75)
				alertController.add(stackView)
				
				if let currentPoints = self?.currentPoints, currentPoints > 0 {
					
					let label = alertController.add(String(key: "game.solo.points.label"))
					alertController.contentStackView.setCustomSpacing(UI.Margins/2, after: label)
					
					let pointsLabel:BB_User_Points_Label = .init("\(currentPoints)" + String(key: "game.solo.points.count"))
					
					let pointsView:UIView = .init()
					pointsView.addSubview(pointsLabel)
					pointsLabel.snp.makeConstraints { make in
						make.top.bottom.centerX.equalToSuperview()
						make.size.lessThanOrEqualToSuperview()
					}
					alertController.add(pointsView)
				}
				
				alertController.addButton(title: String(key: isLastSong ? "game.solo.alert.button.0" : "game.solo.alert.button.1")) { [weak self] _ in
					
					if isLastSong {
						
						alertController.close { [weak self] in
							
							self?.updateUser {
								
								BB_Alert_ViewController.presentLoading { [weak self] controller in
									
									self?.playlist?.success += 1
									self?.playlist?.save { error in
										
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
					}
					else {
						
						self?.currentSongIndex += 1
						
						alertController.close { [weak self] in
							
							self?.start()
						}
					}
				}
				
				if self?.guess.diagnosis == .perfect {
					
					BB_Confettis.stop()
					
					alertController.title = String(key: "game.solo.success.alert.title")
					alertController.present {
						
						if isLastSong {
							
							BB_Confettis.start()
						}
					}
				}
				else {
					
					alertController.title = String(key: "game.solo.failure.alert.title")
					alertController.present()
				}
			}
		}
	}
	
	private func compare(_ string:String?) {
		
		if let guessText = string, let song = playlist?.songs[currentSongIndex] {
			
			let guessResult = song.getGuess(guessText)
			let titleDiagnosis = guessResult.title?.diagnosis ?? .miss
			let artistDiagnosis = guessResult.artist?.diagnosis ?? .miss
			
			if titleDiagnosis == .perfect && artistDiagnosis == .perfect {
					
				guess.artist = guessResult.artist
				guess.title = guessResult.title
				guessTextField.text = nil
				
				if let uuid = playlist?.uuid {
					
					let factor = BB_User.current?.completedPlaylists.contains(uuid) ?? true ? BB_Firebase.shared.getRemoteConfig(.PointsCompletedFactor).numberValue.intValue : 1
					currentPoints += BB_Firebase.shared.getRemoteConfig(.PointsPerfect).numberValue.intValue / factor
					totalPoints += BB_Firebase.shared.getRemoteConfig(.PointsPerfect).numberValue.intValue / factor
				}
				
				stop()
				
			} else {
				
				if artistDiagnosis == .perfect && guess.artist?.diagnosis != .perfect {
					
					guess.artist = guessResult.artist
					guessTextField.text = nil
					songStackView.artistLabel.removeBlur()
					
					if let uuid = playlist?.uuid {
						
						let factor = BB_User.current?.completedPlaylists.contains(uuid) ?? true ? BB_Firebase.shared.getRemoteConfig(.PointsCompletedFactor).numberValue.intValue : 1
						currentPoints += BB_Firebase.shared.getRemoteConfig(.PointsArtist).numberValue.intValue / factor
						totalPoints += BB_Firebase.shared.getRemoteConfig(.PointsArtist).numberValue.intValue / factor
					}
					
					let toastStackView:BB_Toast_StackView = .init()
					toastStackView.style = .Success
					toastStackView.title = String(key: "game.solo.guess.artist.toast.title")
					toastStackView.subtitle = String(key: "game.solo.guess.artist.toast.content")
					toastStackView.present(in: view, position: .Top, from: .Left, to: .Right)
				}
				else if titleDiagnosis == .perfect && guess.title?.diagnosis != .perfect {
					
					guess.title = guessResult.title
					guessTextField.text = nil
					songStackView.titleLabel.removeBlur()
					
					if let uuid = playlist?.uuid {
						
						let factor = BB_User.current?.completedPlaylists.contains(uuid) ?? true ? BB_Firebase.shared.getRemoteConfig(.PointsCompletedFactor).numberValue.intValue : 1
						currentPoints += BB_Firebase.shared.getRemoteConfig(.PointsTitle).numberValue.intValue / factor
						totalPoints += BB_Firebase.shared.getRemoteConfig(.PointsTitle).numberValue.intValue / factor
					}
					
					let toastStackView:BB_Toast_StackView = .init()
					toastStackView.style = .Success
					toastStackView.title = String(key: "game.solo.guess.title.toast.title")
					toastStackView.subtitle = String(key: "game.solo.guess.title.toast.content")
					toastStackView.present(in: view, position: .Top, from: .Left, to: .Right)
				}
				else {
					
					let toastStackView:BB_Toast_StackView = .init()
					toastStackView.style = .Failure
					toastStackView.title = String(key: "game.solo.guess.miss.toast.title")
					toastStackView.subtitle = String(key: "game.solo.guess.miss.toast.content")
					toastStackView.present(in: view, position: .Top, from: .Left, to: .Right)
				}
				
				if guess.diagnosis == .perfect {
					
					stop()
				}
			}
		}
	}
	
	private func updateUser(_ completion:(()->Void)?) {
		
		BB_Alert_ViewController.presentLoading { [weak self] controller in
			
			let user:BB_User = .current ?? .init()
			
			UserDefaults.set(user.level, .userPreviousLevel)
			
			if let playlist = self?.playlist {
				
				user.completedPlaylists.append(playlist.uuid)
			}
			
			user.success += 1
			user.points += self?.totalPoints ?? 0
			user.save { [weak self] error in
				
				controller?.close { [weak self] in
					
					if let error {
						
						BB_Alert_ViewController.present(error) { [weak self] in
							
							self?.updateUser(completion)
						}
					}
					else {
						
						NotificationCenter.post(.updateUser)
						completion?()
					}
				}
			}
		}
	}
	
	private func updateHelpButton() {
		
		UIView.animation {
			
			if !self.isStoppped && self.totalPoints > 50 && (self.guess.artist?.diagnosis != .perfect || self.guess.title?.diagnosis != .perfect) {
				
				self.helpImageView.alpha = 1.0
			}
			else {
				
				self.helpImageView.alpha = 0.0
			}
		}
	}
	
	public override func close() {
		
		BB_Sound.shared.pausePreview()
		
		let alertController:BB_Alert_ViewController = .init()
		alertController.backgroundView.isUserInteractionEnabled = false
		alertController.title = String(key: "game.solo.close.alert.title")
		alertController.add(String(key: "game.solo.close.alert.content"))
		
		let button = alertController.addButton(title: String(key: "game.solo.close.alert.button")) { [weak self] button in
			
			button?.isLoading = true
			
			let user:BB_User = .current ?? .init()
			user.failures += 1
			user.save { [weak self] error in
				
				if let error {
					
					alertController.close {
						
						BB_Alert_ViewController.present(error)
					}
				}
				else {
					
					self?.playlist?.failures += 1
					self?.playlist?.save { [weak self] error in
						
						alertController.close { [weak self] in
							
							if let error {
								
								BB_Alert_ViewController.present(error)
							}
							else {
								
								BB_Sound.shared.stopPreview()
								
								self?.dismiss()
							}
						}
						
					}
				}
			}
		}
		button.type = .delete
		alertController.addCancelButton() { _ in
			
			BB_Sound.shared.resumePreview()
		}
		alertController.present()
	}
	
	public override func dismiss(_ completion: (() -> Void)? = nil) {
		
		super.dismiss({
			
			completion?()
			
			BB_Ads.shared.presentInterstitial(BB_Ads.Identifiers.FullScreen.Game.Solo.End, nil, {
				
				BB_Sound.shared.playMusic()
			})
		})
	}
}

extension BB_Game_Solo_ViewController : UITextFieldDelegate {
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		compare(textField.text)
		
		return true
	}
}
