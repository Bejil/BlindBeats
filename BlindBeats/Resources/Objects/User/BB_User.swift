//
//  BB_User.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import Foundation

public class BB_User : Equatable, Codable {
	
	public static func == (lhs: BB_User, rhs: BB_User) -> Bool {
		
		return lhs.uuid == rhs.uuid
	}
	
	public var uuid: String = UUID().uuidString
	public var name: String?
	public var creationDate: Date = .init()
	public var updateDate: Date = .init()
	public var points:Int = 0
	public var completedPlaylists:[String] = .init()
	public var diamonds:Int = BB_Firebase.shared.getRemoteConfig(.DiamondsUserDefault).numberValue.intValue
}
