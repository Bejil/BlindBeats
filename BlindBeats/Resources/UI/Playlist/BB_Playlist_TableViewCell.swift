//
//  BB_Playlist_TableViewCell.swift
//  BlindBeats
//
//  Created by BLIN Michael on 15/09/2025.
//

import UIKit

public class BB_Playlist_TableViewCell : BB_TableViewCell {
	
	public override class var identifier: String {
		
		return "playlistTableViewCellIdentifier"
	}
	public var playlist:BB_Playlist? {
		
		didSet {
			
			titleLabel.text = playlist?.title
			
			difficultyStackView.backgroundColor = playlist?.difficulty.color
			difficultyLabel.text = String(key: "playlists.difficulty." + (playlist?.difficulty.rawValue ?? BB_Playlist.Difficulty.unknown.rawValue))
			
			tagsView.clearTags()
			tagsView.isHidden = playlist?.user != BB_User.current
			tagsView.addTag("\(playlist?.songs.count ?? 0) " + String(key: "playlists.songs"), backgroundColor: Colors.Primary)
			let genres = playlist?.songs.compactMap({ $0.genre })
			genres?.prefix(5).forEach({
				
				tagsView.addTag($0, backgroundColor: Colors.Tertiary)
			})
			if genres?.count ?? 0 > 5 {
				
				tagsView.addTag("...", backgroundColor: Colors.Content.Text.withAlphaComponent(0.5))
			}
			
			if let createdAt = playlist?.createdAt {
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				
				creationDataLabel.text = String(key: "playlists.date") + dateFormatter.string(from: createdAt) + String(key: "playlists.author") + (playlist?.user?.name ?? "")
				creationDataLabel.set(font: Fonts.Content.Text.Bold.withSize(creationDataLabel.font.pointSize), string: playlist?.user?.name ?? "")
			}
		}
	}
	private lazy var titleLabel: BB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var difficultyStackView:UIStackView = {
		
		$0.layer.cornerRadius = UI.Margins/2
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(horizontal: UI.Margins/2, vertical: UI.Margins/5)
		$0.axis = .horizontal
		$0.spacing = UI.Margins/3
		$0.alignment = .center
		
		let button:UIButton = .init()
		button.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
		button.tintColor = .white
		button.isUserInteractionEnabled = false
		button.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
		$0.addArrangedSubview(button)
		
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			UIApplication.feedBack(.On)
			BB_Sound.shared.playSound(.Button)
			
			let alertController:BB_Playlist_Stats_AlertViewController = .init()
			alertController.playlist = self?.playlist
			alertController.present()
			
		}))
		
		return $0
		
	}(UIStackView(arrangedSubviews: [difficultyLabel]))
	private lazy var difficultyLabel:BB_Label = {
		
		$0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.textColor = .white
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		return $0
		
	}(BB_Label())
	private lazy var creationDataLabel: BB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.alpha = 0.75
		$0.numberOfLines = 1
		return $0
		
	}(BB_Label())
	private lazy var tagsView: BB_Tags_View = .init()
	public var menu:UIMenu? {
		
		get{
			
			return .init(children: [
				
				UIAction(title: String(key: "playlists.action.rename"), image: UIImage(systemName: "square.and.arrow.down"), handler: { [weak self] _ in
					
					self?.renameAction()
				}),
				UIAction(title: String(key: "playlists.action.delete"), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
					
					self?.deleteAction()
				})
			])
		}
	}
	public var leadingSwipeActionsConfiguration:UISwipeActionsConfiguration {
		
		get{
			
			var actionsArray:[UIContextualAction] = .init()
			
			let renameContextualAction:UIContextualAction = .init(style: .normal, title: String(key: "playlists.action.rename")) { [weak self] _, _, completion in
				
				self?.renameAction()
				completion(true)
			}
			renameContextualAction.image = UIImage(systemName: "square.and.arrow.down")
			renameContextualAction.backgroundColor = Colors.Button.Secondary.Background
			actionsArray.append(renameContextualAction)
			
			let actionsConfiguration:UISwipeActionsConfiguration = .init(actions: actionsArray)
			actionsConfiguration.performsFirstActionWithFullSwipe = true
			
			return actionsConfiguration
		}
	}
	public var trailingSwipeActionsConfiguration:UISwipeActionsConfiguration {
		
		get{
			
			var actionsArray:[UIContextualAction] = .init()
			
			let deleteContextualAction:UIContextualAction = .init(style: .destructive, title: String(key: "playlists.action.delete")) { [weak self] _, _, completion in
				
				self?.deleteAction()
				completion(true)
			}
			deleteContextualAction.image = UIImage(systemName: "trash")
			deleteContextualAction.backgroundColor = Colors.Button.Delete.Background
			actionsArray.append(deleteContextualAction)
			
			let actionsConfiguration:UISwipeActionsConfiguration = .init(actions: actionsArray)
			actionsConfiguration.performsFirstActionWithFullSwipe = true
			
			return actionsConfiguration
		}
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let backgroundVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .prominent))
		backgroundVisualEffectView.layer.cornerRadius = UI.CornerRadius
		backgroundVisualEffectView.layer.masksToBounds = true
		contentView.addSubview(backgroundVisualEffectView)
		backgroundVisualEffectView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
			make.left.right.equalToSuperview()
		}
		
		let titleStackView:UIStackView = .init(arrangedSubviews: [titleLabel,difficultyStackView])
		titleStackView.axis = .horizontal
		titleStackView.spacing = UI.Margins
		titleStackView.setCustomSpacing(UI.Margins/2, after: difficultyLabel)
		titleStackView.alignment = .center
		
		let headStackView:UIStackView = .init(arrangedSubviews: [titleStackView,creationDataLabel])
		headStackView.axis = .vertical
		headStackView.spacing = UI.Margins/3
		
		let contentStackView:UIStackView = .init(arrangedSubviews: [headStackView,tagsView])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins/2
		backgroundVisualEffectView.contentView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func renameAction() {
		
		let viewController:BB_Playlist_Alert_Name_ViewController = .init()
		viewController.playlist = playlist
		viewController.present()
	}
	
	private func deleteAction() {
		
		let viewController:BB_PLaylist_Alert_Delete_ViewController = .init()
		viewController.playlist = playlist
		viewController.present() 
	}
}
