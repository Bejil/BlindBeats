//
//  BB_Firebase.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import Firebase
import FirebaseRemoteConfig

public class BB_Firebase {
	
	public enum RemoteConfigKeys:String {
		
		case DiamondsUserDefault = "DiamondsUserDefault"
		case DiamondsGameSolo = "DiamondsGameSolo"
		case DiamondsPerDay = "DiamondsPerDay"
		case PlaylistsMaxSongsCount = "PlaylistsMaxSongsCount"
		case PointsArtist = "PointsArtist"
		case PointsCompletedFactor = "PointsCompletedFactor"
		case PointsHelp = "PointsHelp"
		case PointsPerfect = "PointsPerfect"
		case PointsTitle = "PointsTitle"
	}
	
	public static let shared:BB_Firebase = .init()
	private lazy var remoteConfig:RemoteConfig = RemoteConfig.remoteConfig()
	
	public func start() {
		
		FirebaseApp.configure()
	}
	
	public func prepareRemoteConfig(_ completion:((Error?)->Void)?) {
		
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig.configSettings = settings
		remoteConfig.setDefaults([RemoteConfigKeys.DiamondsUserDefault.rawValue:5 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.DiamondsGameSolo.rawValue:1 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.DiamondsPerDay.rawValue:1 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PlaylistsMaxSongsCount.rawValue:10 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PointsCompletedFactor.rawValue:10 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PointsPerfect.rawValue:150 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PointsArtist.rawValue:60 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PointsTitle.rawValue:60 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.PointsHelp.rawValue:50 as NSObject])
		
		remoteConfig.fetchAndActivate(completionHandler: { _, error in
			
			completion?(error)
		})
	}
	
	public func getRemoteConfig(_ key:RemoteConfigKeys?) -> RemoteConfigValue {
		
		remoteConfig.configValue(forKey: key?.rawValue)
	}
}
