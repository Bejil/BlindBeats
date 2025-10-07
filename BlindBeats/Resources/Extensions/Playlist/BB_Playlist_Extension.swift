//
//  BB_Playlist_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 05/10/2025.
//

import UIKit
import Firebase

extension [BB_Playlist] {

    public var notCompleted: [BB_Playlist] {
        
        return self.filter({ !$0.isCompleted })
    }
    
    public var completed: [BB_Playlist] {
        
        return self.filter({ $0.isCompleted })
    }
}

extension BB_Playlist {
	
	public var isCompleted:Bool {
		
		return BB_User.current?.completedPlaylists.contains(uuid) ?? false
	}
	
	public enum Difficulty: String, CaseIterable {
		
		case veryEasy = "veryEasy"
		case easy = "easy"
		case medium = "medium"
		case hard = "hard"
		case veryHard = "veryHard"
		case unknown = "unknown"
		
		public var color: UIColor {
			
			switch self {
			case .veryEasy: return .systemGreen
			case .easy: return .systemBlue
			case .medium: return .systemYellow
			case .hard: return .systemOrange
			case .veryHard: return .systemRed
			case .unknown: return Colors.Content.Text.withAlphaComponent(0.5)
			}
		}
	}
	
	public var difficulty: Difficulty {
		
		guard attemps >= 5 else { return .unknown }
		
		let successRate = Double(success) / Double(attemps)
		let failureRate = Double(failures) / Double(attemps)
		let averageAttemptsPerSuccess = Double(attemps) / Double(max(success, 1))
		
		let difficultyScore = (failureRate * 0.4) + ((1.0 - successRate) * 0.4) + (min(averageAttemptsPerSuccess / 5.0, 1.0) * 0.2)
		
		if difficultyScore <= 0.2 && successRate >= 0.8 {
			
			return .veryEasy
		}
		else if difficultyScore <= 0.4 && successRate >= 0.6 {
			
			return .easy
		}
		else if difficultyScore <= 0.6 && successRate >= 0.4 {
			
			return .medium
		}
		else if difficultyScore <= 0.8 && successRate >= 0.2 {
			
			return .hard
		}
		else {
			
			return .veryHard
		}
	}
	
	public static func getPlaylists(_ completion:((Error?, [BB_Playlist]?)->Void)?) {
		
		Firestore.firestore().collection("playlists").getDocuments { snapshot, error in
			
			completion?(error,snapshot?.documents.compactMap({
				
				try?$0.data(as: BB_Playlist.self)
			}))
		}
	}
	
	public static func search(title:String?, _ completion:((Error?, [BB_Playlist]?)->Void)?) {
		
		if let searchString = title, !searchString.isEmpty {
			
			let startString = searchString
			let endString = searchString + "\u{f8ff}"
			
			Firestore.firestore().collection("playlists")
				.whereField("title", isGreaterThanOrEqualTo: startString)
				.whereField("title", isLessThanOrEqualTo: endString)
				.getDocuments { snapshot, error in
					
					completion?(error, snapshot?.documents.compactMap({ try?$0.data(as: BB_Playlist.self) }))
				}
		}
		else {
			
			completion?(nil, nil)
		}
	}
	
	public static func search(userName:String?, _ completion:((Error?, [BB_Playlist]?)->Void)?) {
		
		if let searchString = userName, !searchString.isEmpty {
			
			let startString = searchString
			let endString = searchString + "\u{f8ff}"
			
			Firestore.firestore().collection("playlists")
				.whereField("user.name", isGreaterThanOrEqualTo: startString)
				.whereField("user.name", isLessThanOrEqualTo: endString)
				.getDocuments { snapshot, error in
					
					completion?(error, snapshot?.documents.compactMap({ try?$0.data(as: BB_Playlist.self) }))
				}
		}
		else {
			
			completion?(nil, nil)
		}
	}
	
	public func save(_ completion:((_ error:Error?)->Void)?) {
		
		updateDate = .init()
		
		try?Firestore.firestore().collection("playlists").document(uuid).setData(from: self) { error in
			
			completion?(error)
		}
	}
	
	public func delete(_ completion:((_ error:Error?)->Void)?) {
		
		Firestore.firestore().collection("playlists").document(uuid).delete(completion: { error in
			
			completion?(error)
		})
	}
}
