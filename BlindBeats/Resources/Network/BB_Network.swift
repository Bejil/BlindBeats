//
//  BB_Network.swift
//  BlindBeats
//
//  Created by BLIN Michael on 14/03/2025.
//

import Foundation
import Network

public class BB_Network {
	
	public static let shared = BB_Network()
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue.global(qos: .background)
	public var isConnected: Bool?
	private var alertController:BB_Alert_ViewController?
	
	public func start() {
		
		monitor.pathUpdateHandler = { [weak self] path in
			
			self?.isConnected = path.status == .satisfied
			
			DispatchQueue.main.async { [weak self] in
				
				if !(self?.isConnected ?? true) && self?.alertController == nil {
					
					self?.alertController = .init()
					self?.alertController?.backgroundView.isUserInteractionEnabled = false
					self?.alertController?.title = String(key: "alert.error.title")
					self?.alertController?.add(String(key: "network.alert.content"))
					self?.alertController?.present()
				}
				else {
					
					self?.alertController?.close { [weak self] in
						
						self?.alertController = nil
					}
				}
			}
		}
		
		monitor.start(queue: queue)
	}
}
