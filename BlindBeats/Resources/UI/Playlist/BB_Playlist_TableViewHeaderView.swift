//
//  BB_Playlist_TableViewHeaderView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 05/10/2025.
//

import UIKit

public class BB_Playlist_TableViewHeaderView : UITableViewHeaderFooterView {
	
	public class var identifier: String {
		
		return "playlistTableViewHeaderIdentifier"
	}
	public lazy var label:BB_Label = {
		
		$0.font = Fonts.Content.Title.H4.withSize(Fonts.Size)
		$0.textColor = .white
		return $0
		
	}(BB_Label())
	private lazy var backgroundShapeLayer:CAShapeLayer = {
		
		$0.fillColor = Colors.Primary.cgColor
		return $0
		
	}(CAShapeLayer())
	
	public override init(reuseIdentifier: String?) {
		
		super.init(reuseIdentifier: reuseIdentifier)
		
		backgroundView = .init()
		
		contentView.layer.addSublayer(backgroundShapeLayer)
		
		contentView.addSubview(label)
		label.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(UI.Margins)
			make.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.right.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: .init(x: 0, y: UI.Margins/2))
		bezierPath.addLine(to: .init(x: frame.size.width, y: 0))
		bezierPath.addLine(to: .init(x: frame.size.width, y: frame.size.height))
		bezierPath.addLine(to: .init(x: 0, y: frame.size.height))
		bezierPath.close()
		backgroundShapeLayer.path = bezierPath.cgPath
	}
}
