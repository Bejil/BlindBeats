//
//  BB_Song.swift
//  BlindBeats
//
//  Created by BLIN Michael on 19/09/2025.
//

import Foundation

public class BB_Song : Equatable, Codable {
	
	public static func == (lhs: BB_Song, rhs: BB_Song) -> Bool {
		
		return lhs.uuid == rhs.uuid
	}
	
	public var uuid: String = UUID().uuidString
	public var title: String?
	public var artist: String?
	public var album: String?
	public var coverUrl: String?
	public var previewUrl: String?
	public var genre: String?
}
