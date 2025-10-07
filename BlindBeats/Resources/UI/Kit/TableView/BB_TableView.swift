//
//  BB_TableView.swift
//  BlindBeats
//
//  Created by BLIN Michael on 11/09/2025.
//

import UIKit

public class BB_TableView: UITableView {
	
	public var isHeightDynamic:Bool = false
	public override var contentSize: CGSize {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	public var headerView:UIView? {
		
		didSet {
			
			tableHeaderView = headerView
			
			if let headerView = headerView {
				
				tableHeaderView?.snp.makeConstraints { make in
					make.edges.width.equalToSuperview()
				}
				headerView.layoutIfNeeded()
			}
			
			tableHeaderView?.layoutIfNeeded()
		}
	}
	
	public override init(frame: CGRect, style: UITableView.Style) {
		
		super.init(frame: frame, style: style)
		
		clipsToBounds = true
		layer.cornerRadius = UI.CornerRadius
		
		backgroundView = .init()
		
		let backgroundVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
		backgroundView?.addSubview(backgroundVisualEffectView)
		backgroundVisualEffectView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		backgroundColor = .clear
		separatorInset = .zero
		contentInset = .init(top: 0, left: 0, bottom: 3*UI.Margins, right: 0)
		register(BB_TableViewCell.self, forCellReuseIdentifier: BB_TableViewCell.identifier)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func reloadData() {
		
		super.reloadData()
		
		if isHeightDynamic {
			
			invalidateIntrinsicContentSize()
			layoutIfNeeded()
		}
	}
}
