//
//  BB_Room.swift
//  BlindBeats
//
//  Created by BLIN Michael on 22/09/2025.
//

import Foundation
import FirebaseFirestore

public class BB_Room : Codable {
	
	public var uuid: String = UUID().uuidString
	public var owner:BB_User? = BB_User.current
	public var playlist:BB_Playlist?
	public var createdAt:Date = .init()
	public var updateDate:Date = .init()
	public var players:[BB_User] = .init()
	public var isReady:Bool = false
	public var isStarted:Bool = false
	public var isPaused:Bool = false
	public var currentSongIndex:Int = 0
	
	public func save(_ completion:((_ error:Error?)->Void)?) {
		
		updateDate = .init()
		
		try?Firestore.firestore().collection("rooms").document(uuid).setData(from: self) { error in
			
			completion?(error)
		}
	}
	
	public func delete(_ completion:((_ error:Error?)->Void)?) {
		
		Firestore.firestore().collection("rooms").document(uuid).delete(completion: { error in
			
			completion?(error)
		})
	}
	
	public static func get(_ uuid:String?, _ completion:((Error?, BB_Room?)->Void)?) {
		
		Firestore.firestore().collection("rooms").whereField("uuid", isEqualTo: uuid ?? "").limit(to: 1).getDocuments { snapshot, error in
			
			completion?(error,snapshot?.documents.compactMap({ try?$0.data(as: BB_Room.self) }).first)
		}
	}
	
	public func observe(_ completion:((BB_Room?)->Void)?) {
		
		Firestore.firestore().collection("rooms").document(uuid).addSnapshotListener { documentSnapshot, error in
			
			completion?(try?documentSnapshot?.data(as: BB_Room.self))
		}
	}
}
