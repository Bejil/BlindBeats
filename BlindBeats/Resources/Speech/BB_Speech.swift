//
//  BB_Speech.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/09/2025.
//

import Foundation
import Speech

public class BB_Speech {
	
	public static let shared = BB_Speech()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
	private let audioEngine = AVAudioEngine()
	private var recognitionTask: SFSpeechRecognitionTask?
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	
	// Gestion des pauses et phrases complètes
	private var lastRecognizedText = ""
	private var pauseTimer: Timer?
    private let pauseThreshold: TimeInterval = 0.3 // Plage variable
	private var completion: ((String) -> Void)?
	
	public func request(_ completion:((Bool)->Void)?) {
		
		SFSpeechRecognizer.requestAuthorization { authStatus in
			
			DispatchQueue.main.async {
				
				completion?(authStatus == .authorized)
			}
		}
	}
	
	public func recognize(_ completion:((String)->Void)?) {
		
		stop()
		
		// Stocker la completion pour l'utiliser dans le timer
		self.completion = completion
		self.lastRecognizedText = ""
		
		if !audioEngine.isRunning {
			
			startRecording()
		}
	}
	
	public func stop() {
		
		audioEngine.stop()
		
		recognitionTask?.cancel()
		recognitionTask = nil
		
		recognitionRequest?.endAudio()
		recognitionRequest = nil
		
		// Arrêter le timer et retourner le dernier texte reconnu
		pauseTimer?.invalidate()
		pauseTimer = nil
		
		if !lastRecognizedText.isEmpty {
			completion?(lastRecognizedText)
		}
		
		completion = nil
		lastRecognizedText = ""
	}
	
	private func startRecording() {
		
		recognitionTask?.cancel()
		recognitionTask = nil
		
		let audioSession = AVAudioSession.sharedInstance()
		try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
		try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
		
		recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.requiresOnDeviceRecognition = true
		
		guard let recognitionRequest = recognitionRequest else { fatalError("Impossible de créer la requête") }
		
		recognitionRequest.shouldReportPartialResults = true
		
		let inputNode = audioEngine.inputNode
		
		recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
			
			if let result = result {
				let currentText = result.bestTranscription.formattedString
				
				// Si le texte a changé, mettre à jour et redémarrer le timer
				if currentText != self.lastRecognizedText {
					self.lastRecognizedText = currentText
					
					// Redémarrer le timer de pause
					self.pauseTimer?.invalidate()
					self.pauseTimer = Timer.scheduledTimer(withTimeInterval: self.pauseThreshold, repeats: false) { _ in
						
						// Après la pause, retourner la phrase complète
						if !self.lastRecognizedText.isEmpty {
							self.completion?(self.lastRecognizedText)
							self.lastRecognizedText = ""
						}
					}
				}
			}
			
			if error != nil || (result?.isFinal ?? false) {
				
				self.audioEngine.stop()
				inputNode.removeTap(onBus: 0)
				self.recognitionRequest = nil
				self.recognitionTask = nil
				
				// Si c'est final, retourner immédiatement le texte
				if let result = result, !result.bestTranscription.formattedString.isEmpty {
					self.completion?(result.bestTranscription.formattedString)
				}
			}
		}
		
		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
			self.recognitionRequest?.append(buffer)
		}
		
		audioEngine.prepare()
		try? audioEngine.start()
	}
}
