//
//  UIView_Extension.swift
//  BlindBeats
//
//  Created by BLIN Michael on 12/02/2025.
//

import UIKit
import SnapKit

extension UIView {
	
	static func animation(_ duration:TimeInterval? = 0.3, _ animations:@escaping (()->Void), _ completion: (()->Void)? = nil) {
		
		UIView.animate(withDuration: duration ?? 0.3, delay: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: animations) { state in
			
			completion?()
		}
	}
	
	func stopPulse(){
		
		layer.removeAllAnimations()
		transform = .identity
	}
	
	func pulse(_ color:UIColor = Colors.Primary, _ completion:(()->Void)? = nil){
		
		stopPulse()
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		view.subviews.first(where: {$0.accessibilityLabel == "pulseView"})?.removeFromSuperview()
		
		let initialScale = transform
		let initialScaleX = initialScale.a
		let initialScaleY = initialScale.d
		
		superview?.layoutIfNeeded()
		
		let pulseView:UIView = .init()
		pulseView.accessibilityLabel = "pulseView"
		pulseView.isUserInteractionEnabled = false
		
		if color != .clear {
			
			pulseView.backgroundColor = color.withAlphaComponent(0.25)
			pulseView.layer.cornerRadius = frame.size.width/2
			pulseView.layer.borderColor = color.cgColor
			pulseView.layer.borderWidth = 2.0
			pulseView.alpha = 0.0
			pulseView.transform = .init(scaleX: initialScaleX * 0.01, y: initialScaleY * 0.01)
			pulseView.clipsToBounds = true
			addSubview(pulseView)
			
			pulseView.snp.makeConstraints { (make) in
				make.centerX.centerY.width.equalTo(self)
				make.height.equalTo(snp.width)
			}
		}
		
		let pulseDuration:TimeInterval = 0.3
		
		UIView.animate(withDuration: pulseDuration, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
			
			pulseView.transform = .init(scaleX: initialScaleX * 2.0, y: initialScaleY * 2.0)
			
		}, completion: nil)
		
		UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
			
			pulseView.alpha = 0.5
			self?.transform = .init(scaleX: initialScaleX * 1.15, y: initialScaleY * 1.15)
			
		}) { [weak self] _ in
			
			UIView.animate(withDuration: pulseDuration/2, delay: 0.0, options: [.curveEaseInOut, .allowUserInteraction], animations: { [weak self] in
				
				pulseView.alpha=0.0;
				
				self?.transform = initialScale
				
			}) { _ in
				
				if pulseView.superview != nil {
					
					pulseView.removeFromSuperview()
				}
				
				completion?()
			}
		}
	}
	
	@discardableResult func showPlaceholder(_ style:BB_Placeholder_View.Style? = nil, _ error:Error? = nil, _ handler:BB_Button.Handler = nil) -> BB_Placeholder_View {
		
		dismissPlaceholder()
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		
		view.subviews.forEach({ $0.isHidden = true })
		view.layer.sublayers?.forEach({ $0.isHidden = true })
		
		let placeholderView:BB_Placeholder_View = .init(style,error,handler)
		placeholderView.accessibilityLabel = "placeholderView"
		view.addSubview(placeholderView)
		
		placeholderView.snp.makeConstraints { make in
			
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		return placeholderView
	}
	
	func dismissPlaceholder() {
		
		let view:UIView = (self as? UIVisualEffectView)?.contentView ?? self
		view.subviews.first(where: {$0.accessibilityLabel == "placeholderView"})?.removeFromSuperview()
		view.subviews.forEach({ $0.isHidden = false })
		view.layer.sublayers?.forEach({ $0.isHidden = false })
	}
	
	enum LinePosition {
		
		case top, bottom, leading, trailing, center
	}
	
	@discardableResult func addLine(position:LinePosition, color:UIColor? = Colors.Content.Text.withAlphaComponent(0.1), width:Double = 1.0) -> UIView {
		
		let view:UIView = .init()
		view.backgroundColor = color
		addSubview(view)
		
		view.snp.makeConstraints { make in
			
			let topBottomConstraint = {
				
				make.left.right.equalToSuperview()
				make.height.equalTo(width)
			}
			
			let centerConstraint = {
				
				make.left.right.centerY.equalToSuperview()
				make.height.equalTo(width)
			}
			
			let leftRightConstraint = {
				
				make.top.equalToSuperview()
				make.bottom.equalToSuperview()
				make.width.equalTo(width)
			}
			
			switch position {
			case .top:
				topBottomConstraint()
				make.top.equalToSuperview()
			case .bottom:
				topBottomConstraint()
				make.bottom.equalToSuperview()
			case .leading:
				leftRightConstraint()
				make.leading.equalToSuperview()
			case .trailing:
				leftRightConstraint()
				make.trailing.equalToSuperview()
			case .center:
				centerConstraint()
			}
		}
		
		return view
	}
	
	public func addBlur() {
		
		removeBlur()
		
		DispatchQueue.main.async {
			
			var view:UIView = self
			
			if let visualEffectView = self as? UIVisualEffectView {
				
				view = visualEffectView.contentView
			}
			
			let visualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .regular))
			visualEffectView.accessibilityLabel = "blurView"
			visualEffectView.alpha = 0.0
			view.addSubview(visualEffectView)
			visualEffectView.snp.makeConstraints { (make) in
				make.edges.equalToSuperview()
			}
			
			UIView.animation {
				
				visualEffectView.alpha = 1.0
			}
		}
	}
	
	public func removeBlur() {
		
		DispatchQueue.main.async {
			
			var view:UIView = self
			
			if let visualEffectView = self as? UIVisualEffectView {
				
				view = visualEffectView.contentView
			}
			
			let lc_view = view.subviews.first(where: {$0.accessibilityLabel == "blurView"})
			
			UIView.animation(0.3, {
				
				lc_view?.alpha = 0.0
				
			}, {
				
				lc_view?.removeFromSuperview()
			})
		}
	}
	
	func jiggle() {
		
		let amplitude: Float = 7.0 // degrees
		let r = (Float(arc4random()) / Float(RAND_MAX)) - 0.5
		let angleInDegrees = amplitude * (1.0 + r * 0.1)
		let animationRotate = angleInDegrees / 180.0 * .pi
		
			//  Converted to Swift 5.3 by Swiftify v5.3.21043 - https://swiftify.com/
		let duration: TimeInterval = 0.1
		let animation = CABasicAnimation(keyPath: "transform.rotation")
		animation.duration = CFTimeInterval(duration)
		animation.isAdditive = true
		animation.autoreverses = true
		animation.repeatCount = 5
		animation.fromValue = NSNumber(value: -animationRotate)
		animation.toValue = NSNumber(value: animationRotate)
		animation.timeOffset = CFTimeInterval((Float(arc4random()) / Float(RAND_MAX)) * Float(duration))
		layer.add(animation, forKey: "jiggle")
	}
}
