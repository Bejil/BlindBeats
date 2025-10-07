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
		
		case DiamondsUserDefault = "diamondsUserDefault"
		case DiamondsGameSolo = "diamondsGameSolo"
	}
	
	public static let shared:BB_Firebase = .init()
	private lazy var remoteConfig:RemoteConfig = RemoteConfig.remoteConfig()
	
	public func start() {
		
		FirebaseApp.configure()
	}
	
	public func prepareRemoteConfig(_ completion:(()->Void)?) {
		
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig.configSettings = settings
		remoteConfig.setDefaults([RemoteConfigKeys.DiamondsUserDefault.rawValue:5 as NSObject])
		remoteConfig.setDefaults([RemoteConfigKeys.DiamondsGameSolo.rawValue:1 as NSObject])
		remoteConfig.fetchAndActivate(completionHandler: { _, _ in
			
			completion?()
		})
	}
	
	public func getRemoteConfig(_ key:RemoteConfigKeys?) -> RemoteConfigValue {
		
		remoteConfig.configValue(forKey: key?.rawValue)
	}
}
