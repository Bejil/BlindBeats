//
//  BB_Waveform_View.swift
//  BlindBeats
//
//  Created by BLIN Michael on 23/09/2025.
//

import UIKit
import AVFoundation

public class BB_Waveform_View: UIView {
    
    private var progressView: UIProgressView!
    private var maskLayer: CALayer!
    private var animationTimer: Timer?
    private var isAnimating = false
    
    private let barCount = 9
	private let barWidth: CGFloat = 3*UI.Margins/4
	private let barSpacing: CGFloat = UI.Margins/4
	private let maxBarHeight: CGFloat = 7*UI.Margins
    private let minBarHeight: CGFloat = UI.Margins
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveform()
        setupNotifications()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveform()
        setupNotifications()
    }
    
    private func setupWaveform() {
		
		alpha = 0.0
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = Colors.Primary
        progressView.trackTintColor = .white
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing)
            make.height.equalTo(maxBarHeight)
        }
        
        // Créer le masque en forme de barres
        maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        progressView.layer.mask = maskLayer
        
        updateMask()
    }
    
    private func setupNotifications() {
        NotificationCenter.add(.updateSongStatus) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateAnimationState()
            }
        }
        
        NotificationCenter.add(.updateSongProgress) { [weak self] notification in
            DispatchQueue.main.async {
                if let progress = notification.userInfo?["progress"] as? Float {
                    self?.progressView.progress = progress
                }
            }
        }
    }
    
    private func updateAnimationState() {
		
		let isPlaying = BB_Sound.shared.previewIsPlaying
        
        if isPlaying && !isAnimating {
            startAnimation()
        } else if !isPlaying && isAnimating {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
		
		UIView.animation {
			
			self.alpha = 1.0
		}
		
        guard !isAnimating else { return }
        
        isAnimating = true
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { [weak self] _ in
            self?.animateBars()
        }
    }
    
    private func stopAnimation() {
		
		UIView.animation {
			
			self.alpha = 0.0
		}
		
        isAnimating = false
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Arrêter toutes les animations en cours
        maskLayer.removeAllAnimations()
        
        // Remettre le masque à l'état initial
        UIView.animate(withDuration: 0.3) {
            self.updateMask()
        }
    }
    
    private func updateMask() {
        guard let maskLayer = maskLayer else { return }
        
        let totalWidth = CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * barSpacing
        let maskHeight = isAnimating ? maxBarHeight : minBarHeight
        
        maskLayer.frame = CGRect(x: 0, y: 0, width: totalWidth, height: maskHeight)
        
        // Créer le masque en forme de barres
        let maskPath = UIBezierPath()
        
        for i in 0..<barCount {
            let centerIndex = barCount / 2
            let distanceFromCenter = abs(i - centerIndex)
            
            let barHeight: CGFloat
            if isAnimating {
                // Hauteur animée avec variation aléatoire
                let baseHeight = maxBarHeight * (1.0 - CGFloat(distanceFromCenter) * 0.2)
                let randomVariation = CGFloat.random(in: 0.8...1.2)
                barHeight = min(maxBarHeight, max(minBarHeight * 2, baseHeight * randomVariation))
            } else {
                barHeight = minBarHeight
            }
            
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            let yPosition = (maskHeight - barHeight) / 2
            
            let barRect = CGRect(x: xPosition, y: yPosition, width: barWidth, height: barHeight)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 2)
            maskPath.append(barPath)
        }
        
        let maskShapeLayer = CAShapeLayer()
        maskShapeLayer.path = maskPath.cgPath
        maskLayer.mask = maskShapeLayer
    }
    
    private func animateBars() {
        // Animation smooth avec Core Animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.09)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        updateMask()
        CATransaction.commit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }
    
    deinit {
        animationTimer?.invalidate()
        NotificationCenter.remove(.updateSongStatus)
        NotificationCenter.remove(.updateSongProgress)
    }
}
