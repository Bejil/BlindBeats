//
//  AppDelegate.swift
//  BlindBeats
//
//  Created by BLIN Michael on 10/09/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		BB_Network.shared.start()
		BB_Firebase.shared.start()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.backgroundColor = Colors.Background.Application
		
		let navigationController:BB_NavigationController = .init(rootViewController: BB_Home_ViewController())
		navigationController.navigationBar.prefersLargeTitles = false
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
		
		BB_CMP.shared.present { [weak self] in
			
			NotificationCenter.post(.updateAds)
			
			self?.afterLaunch()
		}
		
		return true
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		
		afterLaunch()
	}
	
	private func afterLaunch() {
		
		BB_Ads.shared.presentAppOpening {
			
			BB_Alert_ViewController.presentLoading { controller in
				
				BB_Firebase.shared.prepareRemoteConfig {
					
					controller?.close {
						
						if BB_Network.shared.isConnected ?? true {
							
							if BB_User.current == nil {
								
								let user:BB_User = .init()
								user.save { error in
									
									if let error {
										
										BB_Alert_ViewController.present(error)
									}
									else {
										
										BB_User_Name_Alert_ViewController().present()
									}
								}
							}
							else {
								
								BB_Alert_ViewController.presentLoading { controller in
									
									BB_User.current?.deleteRooms { error in
										
										controller?.close {
											
											if let error {
												
												BB_Alert_ViewController.present(error)
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

