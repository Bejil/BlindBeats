//
//  BB_ToolTip.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit
import TipKit

public class BB_ToolTip : NSObject {
	
	public static var shared: BB_ToolTip = .init()
	public var title: String = ""
	public var message: String?
	public var imageName: String?
	
	private struct CustomTip: Tip {
		let titleText: String
		let messageText: String?
		let imageName: String?
		
		var title: Text {
			Text(titleText)
		}
		
		var message: Text? {
			guard let messageText else { return nil }
			return Text(messageText)
		}
		
		var image: Image? {
			if let imageName = imageName {
				return Image(systemName: imageName)
			}
			return nil
		}
		
		var options: [TipOption] {
			[Tip.IgnoresDisplayFrequency(true)]
		}
	}
	
	public func start() {
		
		try? Tips.configure([
			.displayFrequency(.daily),
			.datastoreLocation(.applicationDefault)])
	}
	
	public func present(from sourceView: UIView) {
		guard !title.isEmpty else { return }
		
		let customTip = CustomTip(
			titleText: title,
			messageText: message,
			imageName: imageName
		)
		
		Task { @MainActor in
			for await shouldDisplay in customTip.shouldDisplayUpdates {
				if shouldDisplay {
					let controller = TipUIPopoverViewController(customTip, sourceItem: sourceView)
					UI.MainController.present(controller,animated: true)
				} else if UI.MainController.presentedViewController is TipUIPopoverViewController {
					UI.MainController.dismiss(animated: true)
				}
			}
		}
	}
}
