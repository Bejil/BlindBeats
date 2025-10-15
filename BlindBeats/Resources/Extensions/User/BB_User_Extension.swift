//
//  BB_User_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 30/09/2025.
//

import Foundation
import FirebaseFirestore

extension BB_User {
	
	public static var current: BB_User? {
		
		if let data = UserDefaults.get(.user) as? Data, let user = try?JSONDecoder().decode(BB_User.self, from: data) {
			
			return user
		}
		
		return nil
	}
	public var level: Int {
		
		let basePoints: Double = 300
		let baseMultiplier: Double = 1.5
		let multiplierGrowth: Double = 0.1
		var currentLevel = 1
		var totalPointsRequired: Double = 0
		
		
		while totalPointsRequired <= Double(points) {
			
			let currentMultiplier = baseMultiplier + (multiplierGrowth * Double(currentLevel - 1))
			let pointsForNextLevel = basePoints * pow(currentMultiplier, Double(currentLevel - 1))
			totalPointsRequired += pointsForNextLevel
			currentLevel += 1
		}
		
		return max(1, currentLevel - 1)
	}
	public var levelProgress: Float {
		
		let currentLevel = self.level
		let basePoints: Double = 300
		let baseMultiplier: Double = 1.5
		let multiplierGrowth: Double = 0.1
		var pointsForCurrentLevel: Double = 0
		
		for level in 1..<currentLevel {
			
			let currentMultiplier = baseMultiplier + (multiplierGrowth * Double(level - 1))
			pointsForCurrentLevel += basePoints * pow(currentMultiplier, Double(level - 1))
		}
		
		let currentMultiplier = baseMultiplier + (multiplierGrowth * Double(currentLevel - 1))
		let pointsForNextLevel = pointsForCurrentLevel + (basePoints * pow(currentMultiplier, Double(currentLevel - 1)))
		let pointsInCurrentLevel = Double(points) - pointsForCurrentLevel
		let pointsNeededForNextLevel = pointsForNextLevel - pointsForCurrentLevel
		let progress = pointsInCurrentLevel / pointsNeededForNextLevel
		
		return Float(max(0.0, min(1.0, progress)))
	}
	public var pointsToNextLevel: Int {
		
		let currentLevel = self.level
		let basePoints: Double = 300
		let baseMultiplier: Double = 1.5
		let multiplierGrowth: Double = 0.1
		var totalPointsRequired: Double = 0
		
		for level in 1...currentLevel {
			
			let currentMultiplier = baseMultiplier + (multiplierGrowth * Double(level - 1))
			totalPointsRequired += basePoints * pow(currentMultiplier, Double(level - 1))
		}
		
		let pointsNeeded = Int(totalPointsRequired) - points
		
		return max(0, pointsNeeded)
	}
	
	public static func checkRewards() {
		
		guard let user = BB_User.current else { return }
		
		let currentLevel = UserDefaults.get(.userPreviousLevel) as? Int ?? 1
		let newLevel = user.level
		
		let levelState = currentLevel < newLevel
		let lastConnectionState = !Calendar.current.isDateInToday(user.lastConnectionDate)
		var lastGameState:Bool {
			
			if let lastGameDate = user.lastGameDate {
				
				return Calendar.current.isDateInToday(lastGameDate)
			}
			
			return false
		}
		var lastDailyGameRewardState:Bool {
			
			if let lastDailyGameRewardDate = user.lastDailyGameRewardDate {
				
				return !Calendar.current.isDateInToday(lastDailyGameRewardDate)
			}
			
			return true
		}
		
		if levelState || lastConnectionState || (lastGameState && lastDailyGameRewardState) {
			
			let alertController:BB_Alert_ViewController = .init()
			alertController.backgroundView.isUserInteractionEnabled = false
			alertController.title = String(key: "user.rewards.alert.title")
			alertController.add(String(key: "user.rewards.alert.content"))
			
			if levelState {
				
				var totalDiamonds = 0
				for level in (currentLevel + 1)...newLevel {
					
					totalDiamonds += Int(round(Double(level) * 0.5 + 2))
				}
				
				let button = alertController.addButton(title: String(key: "user.rewards.levelup.alert.button")) { button in
					
					button?.isLoading = true
					
					let user:BB_User = .current ?? .init()
					user.diamonds += totalDiamonds
					user.save { error in
						
						button?.isLoading = false
						
						if let error {
							
							BB_Alert_ViewController.present(error)
						}
						else {
							
							UserDefaults.set(user.level, .userPreviousLevel)
							
							button?.isEnabled = false
							NotificationCenter.post(.updateUser)
						}
					}
				}
				button.subtitle = ["\(totalDiamonds)",String(key: "user.diamonds")].joined(separator: " ")
			}
			
			if lastConnectionState {
				
				let button = alertController.addButton(title: String(key: "user.rewards.connexion.alert.button")) { button in
					
					button?.isLoading = true
					
					let user:BB_User = .current ?? .init()
					user.lastConnectionDate = Date()
					user.diamonds += BB_Firebase.shared.getRemoteConfig(.DiamondsPerDay).numberValue.intValue
					user.save { error in
						
						button?.isLoading = false
						
						if let error {
							
							BB_Alert_ViewController.present(error)
						}
						else {
							
							button?.isEnabled = false
							NotificationCenter.post(.updateUser)
						}
					}
				}
				button.subtitle = ["\(BB_Firebase.shared.getRemoteConfig(.DiamondsPerDay).numberValue.intValue)",String(key: "user.diamonds")].joined(separator: " ")
			}
			
			if lastGameState && lastDailyGameRewardState {
				
				let button = alertController.addButton(title: String(key: "user.rewards.game.alert.button")) { button in
					
					button?.isLoading = true
					
					let user:BB_User = .current ?? .init()
					user.lastDailyGameRewardDate = .init()
					user.diamonds += BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue
					user.save { error in
						
						button?.isLoading = false
						
						if let error {
							
							BB_Alert_ViewController.present(error)
						}
						else {
							
							button?.isEnabled = false
							NotificationCenter.post(.updateUser)
						}
					}
				}
				button.subtitle = ["\(BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue)",String(key: "user.diamonds")].joined(separator: " ")
			}
			
			NotificationCenter.add(.updateUser) { _ in
				
				if (alertController.contentStackView.arrangedSubviews.filter({ $0 is BB_Button }) as? [BB_Button])?.allSatisfy({ !$0.isEnabled }) ?? true {
					
					alertController.close()
				}
			}
			
			alertController.dismissHandler = {
				
				BB_Confettis.stop()
			}
			alertController.present() {
				
				BB_Confettis.start()
			}
		}
	}
	
	private static func pointsRequiredForLevel(_ level: Int) -> Int {
		
		guard level > 0 else { return 0 }
		
		let basePoints: Double = 300
		let baseMultiplier: Double = 1.5
		let multiplierGrowth: Double = 0.1
		
		var totalPoints: Double = 0
		for currentLevel in 1..<level {
			let currentMultiplier = baseMultiplier + (multiplierGrowth * Double(currentLevel - 1))
			totalPoints += basePoints * pow(currentMultiplier, Double(currentLevel - 1))
		}
		
		return Int(totalPoints)
	}
	
	public static func search(_ name:String?, _ completion:((Error?,[BB_User]?)->Void)?) {
		
		if let searchName = name, !searchName.isEmpty {
			
			Firestore.firestore().collection("users")
				.whereField("name", isGreaterThanOrEqualTo: searchName)
				.whereField("name", isLessThanOrEqualTo: searchName + "\u{f8ff}")
				.getDocuments { userSnapshot, userError in
					
					let matchingUsers = userSnapshot?.documents.compactMap({ try?$0.data(as: BB_User.self) }).filter { user in
						user.name?.lowercased().contains(searchName.lowercased()) == true
					} ?? []
					
					completion?(userError, matchingUsers)
				}
		}
		else {
			
			completion?(nil, nil)
		}
	}
	
	public func save(_ completion:((_ error:Error?)->Void)?) {
		
		updateDate = .init()
		
		try?Firestore.firestore().collection("users").document(uuid).setData(from: self) { error in
			
			if error == nil {
				
				if let data = try?JSONEncoder().encode(self) {
					
					UserDefaults.set(data, .user)
				}
			}
			
			completion?(error)
		}
	}
	
	public func getPlaylists(_ completion:((Error?, [BB_Playlist]?)->Void)?) {
		
		Firestore.firestore().collection("playlists").whereField("user.uuid", isEqualTo: uuid).getDocuments { snapshot, error in
			
			completion?(error,snapshot?.documents.compactMap({ try?$0.data(as: BB_Playlist.self) }))
		}
	}
	
	public static func checkName(_ name: String?, _ completion: @escaping (_ isAvailable: Bool, _ error: Error?) -> Void) {
		
		Firestore.firestore().collection("users").whereField("name", isEqualTo: name ?? "").limit(to: 1).getDocuments { snapshot, error in
			
			if let error = error {
				
				completion(false, error)
				return
			}
			
			let isAvailable = snapshot?.documents.isEmpty ?? true
			completion(isAvailable, nil)
		}
	}
	
	public static func get(_ completion:((Error?,[BB_User]?)->Void)?) {
		
		Firestore.firestore().collection("users").order(by: "points", descending: true).getDocuments { snapshot, error in
			
			completion?(error, snapshot?.documents.compactMap({ try?$0.data(as: BB_User.self) }))
		}
	}
	
	public func startGame(_ completion:(()->Void)?) {
		
		if diamonds < BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue {
			
			let alertController:BB_Alert_ViewController = .init()
			alertController.title = String(key: "user.game.solo.alert.title")
			alertController.add(String(key: "user.game.solo.alert.error.0") + String(key: "user.diamonds") + String(key: "user.game.solo.alert.error.1"))
			alertController.addButton(title: String(key: "user.game.solo.alert.button")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BB_NavigationController(rootViewController: BB_Shop_ViewController()), animated: true)
				}
			}
			alertController.addDismissButton()
			alertController.present()
		}
		else {
			
			let alertController:BB_Alert_ViewController = .init()
			alertController.title = String(key: "user.game.solo.alert.title")
			alertController.add(String(key: "user.game.solo.alert.content"))
			let button = alertController.addButton(title: String(key: "user.game.solo.alert.button.title")) { _ in
				
				alertController.close {
					
					completion?()
				}
			}
			button.subtitle = [String(key: "user.game.solo.alert.button.subtitle"),"\(BB_Firebase.shared.getRemoteConfig(.DiamondsGameSolo).numberValue.intValue)",String(key: "user.diamonds")].joined(separator: " ")
			alertController.addCancelButton()
			alertController.present()
		}
	}
}
