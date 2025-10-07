//
//  BB_Song.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import UIKit
import MusicKit

extension BB_Song {
	
	public class Guess : Codable {
		
		public enum Diagnosis : CaseIterable {
			
			case perfect, almost, far, miss
			
			public static func get(for score:Double?) -> Diagnosis {
				
				switch score ?? 0.0 {
				case 0.85...1.0: return .perfect
				case 0.7..<0.85: return .almost
				case 0.5..<0.7: return .far
				default: return .miss
				}
			}
		}
		
		public class Similarity : Codable {
			
			public var score: Double?
			public var diagnosis:Diagnosis {
				
				return Diagnosis.get(for: score)
			}
		}
		
		public var artist:Similarity?
		public var title:Similarity?
		public var diagnosis:Diagnosis {
			
			return Diagnosis.get(for: ((artist?.score ?? 0.0) + (title?.score ?? 0.0))/2.0)
		}
	}
	
	public static func get(_ query:String?, _ completion:(([BB_Song]?)->Void)?) {
		
		Task {
			
			do {
				
				let request = MusicCatalogSearchRequest(term: query ?? "", types: [Song.self])
				let response = try await request.response()
				
				await MainActor.run {
					
					completion?(response.songs.compactMap({
						
						let song:BB_Song = .init()
						song.title = $0.title
						song.artist = $0.artistName
						song.album = $0.albumTitle
						song.genre = $0.genreNames.first
						
						let coverSize = Int(UI.Margins*10*UIScreen.main.scale)
						song.coverUrl = $0.artwork?.url(width: coverSize, height: coverSize)?.absoluteString
						
						song.previewUrl = $0.previewAssets?.first?.url?.absoluteString
						
						return song
					}))
				}
			}
			catch {
				
				await MainActor.run {
					
					completion?(nil)
				}
			}
		}
	}
	
	public func getGuess(_ string:String?) -> BB_Song.Guess {
		
		let guess = string?.normalized()
		
		let result:BB_Song.Guess = .init()
		
		let titleScore = guess?.similarityScore(to: title) ?? 0.0
		
		let artistScore = guess?.similarityScore(to: artist) ?? 0.0
		
		let fullTitle1 = "\(artist ?? "") \(title ?? "")"
		let fullScore1 = guess?.similarityScore(to: fullTitle1) ?? 0.0
		
		let fullTitle2 = "\(title ?? "") \(artist ?? "")"
		let fullScore2 = guess?.similarityScore(to: fullTitle2) ?? 0.0
		
		result.title = .init()
		result.title?.score = max(titleScore, fullScore1, fullScore2)
		
		result.artist = .init()
		result.artist?.score = max(artistScore, fullScore1, fullScore2)
		
		return result
	}
}
