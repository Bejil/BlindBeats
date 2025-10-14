//
//  BB_Settings_Button.swift
//  BlindBeats
//
//  Created by BLIN Michael on 22/08/2025.
//

import UIKit

public class BB_Settings_Button : BB_Button {
	
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			
			UIAction(title: String(key: "settings.sounds"), subtitle: String(key: "settings.sounds." + (BB_Sound.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: BB_Sound.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				UserDefaults.set(!BB_Sound.shared.isSoundsEnabled, .soundsEnabled)
				BB_Sound.shared.playSound(.Button)
				
				self?.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "settings.music"), subtitle: String(key: "settings.music." + (BB_Sound.shared.isMusicEnabled ? "on" : "off")), image: UIImage(systemName: BB_Sound.shared.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
				
				UserDefaults.set(!BB_Sound.shared.isMusicEnabled, .musicEnabled)
				BB_Sound.shared.playSound(.Button)
				BB_Sound.shared.isMusicEnabled ? BB_Sound.shared.playMusic() : BB_Sound.shared.stopMusic()
				
				self?.menu = self?.settingsMenu
			}),
			UIAction(title: String(key: "settings.vibrations"), subtitle: String(key: "settings.vibrations." + (UIApplication.isVibrationsEnabled ? "on" : "off")), image: UIImage(systemName: UIApplication.isVibrationsEnabled ? "water.waves" : "water.waves.slash"), handler: { [weak self] _ in
				
				UserDefaults.set(!UIApplication.isVibrationsEnabled, .vibrationsEnabled)
				BB_Sound.shared.playSound(.Button)
				
				self?.menu = self?.settingsMenu
			})
		])
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		title = String(key: "settings.button")
		image = UIImage(systemName: "slider.vertical.3")?.applyingSymbolConfiguration(.init(scale: .medium))
		menu = settingsMenu
		showsMenuAsPrimaryAction = true
		type = .navigation
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
