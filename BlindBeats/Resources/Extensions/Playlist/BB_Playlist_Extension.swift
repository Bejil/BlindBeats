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
			case .veryEasy: return Colors.Playlist.VeryEasy
			case .easy: return Colors.Playlist.Easy
			case .medium: return Colors.Playlist.Medium
			case .hard: return Colors.Playlist.Hard
			case .veryHard: return Colors.Playlist.VeryHard
			case .unknown: return Colors.Playlist.Unknown
			}
		}
	}
	
	public var difficulty: Difficulty {
		
		if attemps == 0 {
			
			return .unknown
		}
		
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
	
	public var placeholder:String? {
		
		let genres = songs.compactMap { $0.genre }.filter { !$0.isEmpty }
		let genreCounts = Dictionary(grouping: genres, by: { $0 })
			.mapValues { $0.count }
			.sorted { $0.value > $1.value }
		
		if !genreCounts.isEmpty {
			
			let totalSongs = genreCounts.reduce(0) { $0 + $1.value }
			let mostCommonGenre = genreCounts[0]
			let mostCommonPercentage = Double(mostCommonGenre.value) / Double(totalSongs) * 100
			
			if mostCommonPercentage >= 60 {
				
				return String(key: "playlists.edit.title.alert.placeholder.1") + "\(mostCommonGenre.key)"
			}
			
			if genreCounts.count >= 2 {
				
				let topTwoPercentage = Double(mostCommonGenre.value + genreCounts[1].value) / Double(totalSongs) * 100
				
				if topTwoPercentage >= 80 {
					
					return "\(mostCommonGenre.key) & \(genreCounts[1].key)"
				}
			}
			
			if genreCounts.count >= 3 {
				
				let topThree = genreCounts.prefix(3).map { $0.key }
				return String(key: "playlists.edit.title.alert.placeholder.2") + "\(topThree.joined(separator: ", "))"
			}
			
			if genreCounts.count == 2 {
				
				return "\(mostCommonGenre.key) & \(genreCounts[1].key)"
			}
			
			return String(key: "playlists.edit.title.alert.placeholder.1") + "\(mostCommonGenre.key)"
		}
		
		return nil
	}
}
