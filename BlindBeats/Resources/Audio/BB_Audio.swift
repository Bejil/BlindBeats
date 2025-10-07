//
//  BB_Audio.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/06/2022.
//

import Foundation
import SwiftySound
import AVFoundation
import MusicKit

public class BB_Audio : NSObject {
	
	public enum Keys : String, CaseIterable {
		
		case success = "Success"
		case error = "Error"
		case button = "Button"
		case tap = "Tap"
	}
	
	private var currentMusic:Sound?
	private var previewPlayer: AVPlayer?
	public var currentlyPlayingSong: BB_Song?
	private var progressTimer: Timer?
	private var playCompletion: (() -> Void)?
	public static let shared:BB_Audio = .init()
	
	deinit {
		
		NotificationCenter.remove(.AVPlayerItemDidPlayToEndTime)
		stopPreview()
	}
	
	public override init() {
		
		super.init()
		
		Sound.category = .playback
		
		NotificationCenter.add(.AVPlayerItemDidPlayToEndTime) { [weak self] _ in
			
			DispatchQueue.main.async { [weak self] in
				
				self?.playCompletion?()
				self?.playCompletion = nil
				self?.stopPreview()
			}
		}
	}
	
	public func play(_ sound: Keys) {
		
		DispatchQueue.global(qos: .background).async {
			
			Sound.play(file: "\(sound.rawValue).mp3")
		}
	}
	
	public func playPreview(for song: BB_Song?, completion: (() -> Void)? = nil) {
		
		if currentlyPlayingSong == song {
			
			stopPreview()
			return
		}
		
		stopPreview()
		
		playCompletion = completion
		
		if let preview = song?.previewUrl, let url = URL(string: preview) {
			
			previewPlayer = AVPlayer(url: url)
			currentlyPlayingSong = song
			
			NotificationCenter.post(.updateSongStatus)
			
			startProgressTimer()
			
			previewPlayer?.play()
		}
		else {
			
			completion?()
			playCompletion = nil
		}
	}
	
	public func pausePreview() {
		
		previewPlayer?.pause()
		stopProgressTimer()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	public func resumePreview() {
		
		previewPlayer?.play()
		startProgressTimer()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	public func stopPreview() {
		
		previewPlayer?.pause()
		previewPlayer = nil
		currentlyPlayingSong = nil
		playCompletion = nil
		stopProgressTimer()
		
		NotificationCenter.post(.updateSongStatus)
	}
	
	public func isPlayingPreview(for song: BB_Song?) -> Bool {
		
		return currentlyPlayingSong == song
	}
	
	private func startProgressTimer() {
		
		stopProgressTimer()
		
		progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
			
			self?.updateProgress()
		}
	}
	
	private func stopProgressTimer() {
		
		progressTimer?.invalidate()
		progressTimer = nil
	}
	
	private func updateProgress() {
		
		guard let player = previewPlayer,
			  let currentItem = player.currentItem else { return }
		
		let currentTime = player.currentTime()
		let duration = currentItem.duration
		
		guard duration.isNumeric && duration.seconds > 0 else { return }
		
		let progress = Float(currentTime.seconds / duration.seconds)
		let clampedProgress = max(0.0, min(1.0, progress))
		
		NotificationCenter.post(.updateSongProgress, userInfo: ["progress": clampedProgress])
	}
}
