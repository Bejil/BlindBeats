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
	
	public func deleteRooms(_ completion:((Error?)->Void)?) {
		
		Firestore.firestore().collection("rooms").whereField("owner.uuid", isEqualTo: uuid).getDocuments { snapshot, error in
			
			let rooms = snapshot?.documents.compactMap({ try?$0.data(as: BB_Room.self) })
			rooms?.forEach({
				
				Firestore.firestore().collection("rooms").document($0.uuid).delete()
			})
			
			completion?(error)
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
}
