//
//  BB_Tags_View.swift
//  BlindBeats
//
//  Created by BLIN Michael on 16/09/2025.
//

import UIKit

public class BB_Tags_View : UIView {
	
	private var tags: [String] = [] {
		
		didSet {
			
			updateTags()
		}
	}
	private var spacing = UI.Margins/3
	private var tagLabels: [BB_Label] = []
	private var tagBackgroundColors: [String: UIColor] = [:]
	private lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = spacing
		$0.alignment = .leading
		$0.distribution = .fill
		return $0
		
	}(UIStackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		backgroundColor = .clear
		
		addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	public required init?(coder: NSCoder) {
		
		super.init(coder: coder)
	}
	
	public func addTag(_ tag: String, backgroundColor: UIColor? = nil) {
		
		if !tags.contains(tag) {
			
			tags.append(tag)
			// Stocker la couleur de fond pour ce tag si fournie
			if let backgroundColor = backgroundColor {
				tagBackgroundColors[tag] = backgroundColor
			}
		}
	}
	
	public func removeTag(_ tag: String) {
		
		tags.removeAll { $0 == tag }
		tagBackgroundColors.removeValue(forKey: tag)
	}
	
	public func addTags(_ tags: [(text: String, backgroundColor: UIColor?)]) {
		
		for tag in tags {
			addTag(tag.text, backgroundColor: tag.backgroundColor)
		}
	}
	
	public func clearTags() {
		
		tags.removeAll()
		tagBackgroundColors.removeAll()
	}
	
	private func updateTags() {
		
		tagLabels.forEach { $0.removeFromSuperview() }
		tagLabels.removeAll()
		stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
		
		if !tags.isEmpty {
			
			var currentLineStackView: UIStackView?
			var currentLineWidth: CGFloat = 0
			let availableWidth = frame.width > 0 ? frame.width : UIScreen.main.bounds.width - 2*UI.Margins
			
			for tag in tags {
				
				let tagLabel = createTagLabel(for: tag)
				let tagWidth = calculateTagWidth(for: tag)
				
				if currentLineWidth + tagWidth + (currentLineStackView != nil ? spacing : 0) <= availableWidth {
						
					if currentLineStackView == nil {
						
						currentLineStackView = createLineStackView()
						stackView.addArrangedSubview(currentLineStackView!)
					}
					
					currentLineStackView?.addArrangedSubview(tagLabel)
					currentLineWidth += tagWidth + (currentLineStackView?.arrangedSubviews.count ?? 0 > 1 ? spacing : 0)
				}
				else {
					
					currentLineStackView = createLineStackView()
					stackView.addArrangedSubview(currentLineStackView!)
					currentLineStackView?.addArrangedSubview(tagLabel)
					currentLineWidth = tagWidth
				}
				
				tagLabels.append(tagLabel)
			}
		}
	}
	
	private func createLineStackView() -> UIStackView {
		
		let lineStackView = UIStackView()
		lineStackView.axis = .horizontal
		lineStackView.spacing = spacing
		lineStackView.alignment = .center
		lineStackView.distribution = .fill
		return lineStackView
	}
	
	private func createTagLabel(for tag: String) -> BB_Label {
		
		let label = BB_Label()
		label.text = tag
		label.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 1
		label.backgroundColor = tagBackgroundColors[tag] ?? Colors.Secondary
		label.layer.cornerRadius = UI.Margins/2
		label.contentInsets = .init(horizontal: UI.Margins/5, vertical: UI.Margins/7)
		return label
	}
	
	private func calculateTagWidth(for tag: String) -> CGFloat {
		
		let textSize = tag.size(withAttributes: [.font: Fonts.Content.Text.Bold.withSize(Fonts.Size-2)])
		return textSize.width + (2*(UI.Margins/5))
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		if !tags.isEmpty {
			
			updateTags()
		}
	}
}
