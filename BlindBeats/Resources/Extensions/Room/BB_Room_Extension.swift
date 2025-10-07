//
//  BB_Room_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 25/09/2025.
//

import UIKit
import NotificationToast

extension BB_Room {
	
	public func promptPlayerToast(for newRoom:BB_Room?) {
		
		if let newRoom {
			
			var diff = newRoom.players.count - players.count
			
			let difference = newRoom.players.difference(from: players)
			if difference.count == 1 {
				let change = difference.first
				if case .insert(_, let newPlayer, _) = change, newPlayer == owner {
					
					return
				}
			}
			
			if diff > 0 {
				
				let toast = ToastView(
					title: String(key: "rooms.create.toast.add.title"),
					titleFont: Fonts.Content.Title.H4,
					subtitle: "\(diff)" + String(key: diff == 1 ? "rooms.create.toast.add.single.message" : "rooms.create.toast.add.multiple.message"),
					subtitleFont: Fonts.Content.Text.Regular,
					icon: UIImage(systemName: "person.badge.plus"),
					iconSpacing: UI.Margins,
					position: .top
				)
				toast.displayTime = 3.0
				toast.show()
			}
			else {
				
				diff = abs(diff)
				
				if diff > 0 {
					
					let toast = ToastView(
						title: String(key: "rooms.create.toast.remove.title"),
						titleFont: Fonts.Content.Title.H4,
						subtitle: "\(diff)" + String(key: diff == 1 ? "rooms.create.toast.remove.single.message" : "rooms.create.toast.remove.multiple.message"),
						subtitleFont: Fonts.Content.Text.Regular,
						icon: UIImage(systemName: "person.badge.minus"),
						iconSpacing: UI.Margins,
						position: .top
					)
					toast.displayTime = 3.0
					toast.show()
				}
			}
		}
	}
}
