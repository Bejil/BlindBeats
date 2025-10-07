//
//  BB_Playlist.swift
//  BlindBeats
//
//  Created by BLIN Michael on 19/09/2025.
//

import Foundation

public class BB_Playlist : Equatable, Codable {
	
	public static func == (lhs: BB_Playlist, rhs: BB_Playlist) -> Bool {
		
		return lhs.uuid == rhs.uuid
	}
	
	public var uuid: String = UUID().uuidString
	public var user: BB_User?
	public var title: String?
	public var songs:[BB_Song] = .init()
	public var createdAt:Date = .init()
	public var updateDate:Date = .init()
	public var attemps:Int = 0
	public var success:Int = 0
	public var failures:Int = 0
}
