//
//  BB_Sound.swift
//  BlindBeats
//
//  Created by BLIN Michael on 09/10/2025.
//

import AVFoundation

public class BB_Sound : NSObject {
	
	public enum Sounds : String {
		
		case Success = "Success"
		case Error = "Error"
		case Button = "Button"
		case Tap = "Tap"
	}
	
	public static var shared:BB_Sound = .init()
	private var currentPreview:BB_Song?
	public var previewIsPlaying:Bool {
		
		return currentPreview != nil
	}
	private var previewPlayer:AVPlayer?
	private var previewEndCompletion:(()->Void)?
	private var previewProgressTimer:Timer?
	
	private var soundPlayer:AVAudioPlayer?
	private var musicPlayer:AVAudioPlayer?
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	public var isMusicEnabled:Bool {
		
		return (UserDefaults.get(.musicEnabled) as? Bool) ?? true
	}
	
	deinit {
		
		stopPreview()
	}
	
	public func playPreview(_ song:BB_Song?, _ completion:(()->Void)? = nil) {
		
		stopPreview()
		
		if let previewUrl = song?.previewUrl, let url = URL(string: previewUrl) {
			
			// S'assurer que la session audio est configurée pour la lecture
			try? AVAudioSession.sharedInstance().setCategory(.playback)
			try? AVAudioSession.sharedInstance().setActive(true)
			
			previewEndCompletion = completion
			
			previewPlayer = .init(url: url)
			previewPlayer?.play()
			
			currentPreview = song
			
			NotificationCenter.post(.updateSongStatus)
			
			NotificationCenter.default.addObserver(self, selector: #selector(previewDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: previewPlayer?.currentItem)
			
			previewProgressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
				
				self?.updatePreviewProgress()
			}
		}
	}
	
	public func pausePreview() {
		
		previewPlayer?.pause()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	public func resumePreview() {
		
		previewPlayer?.play()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	public func stopPreview() {
		
		currentPreview = nil
		
		previewProgressTimer?.invalidate()
		previewProgressTimer = nil
		
		previewEndCompletion = nil
		
		previewPlayer?.seek(to: CMTime.zero)
		previewPlayer?.pause()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	@objc private func previewDidFinishPlaying(notification:Notification) {
		
		previewEndCompletion?()
		stopPreview()
	}
	
	private func updatePreviewProgress() {
		
		if let previewPlayer, let currentItem = previewPlayer.currentItem {
			
			let currentTime = previewPlayer.currentTime()
			let duration = currentItem.duration
			
			if duration.isNumeric && duration.seconds > 0 {
				
				let progress = Float(currentTime.seconds / duration.seconds)
				let clampedProgress = max(0.0, min(1.0, progress))
				
				NotificationCenter.post(.updateSongProgress, userInfo: ["progress": clampedProgress])
			}
		}
	}
	
	public func isPlayingPreview(for song: BB_Song?) -> Bool {
		
		return currentPreview == song
	}
	
	public func playSound(_ sound:Sounds) {
		
		stopSound()
		
		if isSoundsEnabled, let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			try?AVAudioSession.sharedInstance().setCategory(.playback)
			try?AVAudioSession.sharedInstance().setActive(true)
			
			try?soundPlayer = AVAudioPlayer(contentsOf: url)
			soundPlayer?.prepareToPlay()
			soundPlayer?.play()
		}
	}
	
	private func stopSound() {
		
		soundPlayer?.stop()
		soundPlayer = nil
	}
	
	public func playMusic() {
		
		stopMusic()
		
		if isMusicEnabled, let index = (0...2).randomElement(), let path = Bundle.main.path(forResource: "music_\(index)", ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			try?AVAudioSession.sharedInstance().setCategory(.playback)
			try?AVAudioSession.sharedInstance().setActive(true)
			
			try?musicPlayer = AVAudioPlayer(contentsOf: url)
			musicPlayer?.delegate = self
			musicPlayer?.prepareToPlay()
			musicPlayer?.play()
		}
	}
	
	public func stopMusic() {
		
		musicPlayer?.stop()
		musicPlayer = nil
	}
}

extension BB_Sound : AVAudioPlayerDelegate {
	
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		
		playMusic()
	}
}
