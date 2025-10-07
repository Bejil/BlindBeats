//
//  BB_Song_Play_Button.swift
//  BlindBeats
//
//  Created by BLIN Michael on 16/09/2025.
//

import UIKit

public class BB_Song_Play_Button : UIButton {
	
	public var song: BB_Song? {
		
		didSet {
			
			updateButtonState()
		}
	}
	public var isPlaying: Bool = false {
		
		didSet {
			
			updatePlayButtonState()
		}
	}
	public var color:UIColor? {
		
		didSet {
			
			playImageView.tintColor = color
		}
	}
	private lazy var playImageView: BB_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.isUserInteractionEnabled = false
		$0.tintColor = Colors.Secondary
		return $0
		
	}(BB_ImageView(image: UIImage(systemName: "play.circle.fill")))
	public var progressColor:UIColor? {
		
		didSet {
			
			progressLayer.strokeColor = progressColor?.cgColor
		}
	}
	private lazy var progressLayer: CAShapeLayer = {
		
		$0.fillColor = UIColor.clear.cgColor
		$0.strokeColor = Colors.Tertiary.cgColor
		$0.lineWidth = UI.Margins/2
		$0.strokeEnd = 0.0
		return $0
		
	}(CAShapeLayer())
	public override var isEnabled: Bool {
		
		didSet {
			
			alpha = isEnabled ? 1.0 : 0.25
		}
	}
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setupButton()
	}
	
	required init?(coder: NSCoder) {
		
		super.init(coder: coder)
		
		setupButton()
	}
	
	private func setupButton() {
		
		backgroundColor = .clear
		
		addSubview(playImageView)
		playImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
			make.size.equalTo(2.5*UI.Margins)
		}
		
		playImageView.layer.addSublayer(progressLayer)
		
		addAction(.init(handler: { [weak self] _ in
			
			if let song = self?.song {
				
				if BB_Audio.shared.isPlayingPreview(for: song) {
					
					BB_Audio.shared.stopPreview()
				}
				else {
					
					BB_Audio.shared.playPreview(for: song)
				}
			}
			
		}), for: .touchUpInside)
		
		NotificationCenter.add(.updateSongStatus) { [weak self] _ in
			
			self?.isPlaying = BB_Audio.shared.isPlayingPreview(for: self?.song)
		}
		
		NotificationCenter.add(.updateSongProgress) { [weak self] notification in
			
			if let progress = notification.userInfo?["progress"] as? Float, self?.isPlaying ?? false, BB_Audio.shared.isPlayingPreview(for: self?.song) {
				
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				self?.progressLayer.strokeEnd = CGFloat(progress)
				CATransaction.commit()
			}
		}
	}
	
	private func updateButtonState() {
		
		isEnabled = song?.previewUrl != nil
		isPlaying = BB_Audio.shared.isPlayingPreview(for: song)
	}
	
	private func updatePlayButtonState() {
		
		playImageView.image = UIImage(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
		progressLayer.isHidden = !isPlaying
		
		if !isPlaying {
			
			progressLayer.strokeEnd = 0.0
		}
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let center = CGPoint(x: playImageView.bounds.midX, y: playImageView.bounds.midY)
		let radius = min(playImageView.bounds.width, playImageView.bounds.height) / 2
		let startAngle = -CGFloat.pi / 2
		let endAngle = startAngle + 2 * CGFloat.pi
		
		let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		progressLayer.path = path.cgPath
	}
}
