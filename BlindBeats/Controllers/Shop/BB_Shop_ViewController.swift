//
//  BB_Shop_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 06/10/2025.
//

import UIKit
import StoreKit

public class BB_Shop_ViewController : BB_ViewController {
	
	private var products:[Product]? {
		
		didSet {
			
			tableView.dismissPlaceholder()
			
			if products?.isEmpty ?? true {
				
				tableView.showPlaceholder(.Empty)
			}
			
			tableView.reloadData()
		}
	}
	private lazy var tableView:BB_TableView = {
		
		$0.register(BB_Shop_TableViewCell.self, forCellReuseIdentifier: BB_Shop_TableViewCell.identifier)
		$0.clipsToBounds = false
		$0.delegate = self
		$0.dataSource = self
		$0.backgroundView = .init()
		$0.separatorStyle = .none
		return $0
		
	}(BB_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		title = String(key: "shop.title")
		
		let restoreTitleLabel:BB_Label = .init(String(key: "shop.restore.title"))
		restoreTitleLabel.font = Fonts.Content.Title.H4.withSize(Fonts.Content.Title.H4.pointSize-2)
		restoreTitleLabel.textColor = .white
		restoreTitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
		restoreTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		
		let restoreLabel:BB_Label = .init(String(key: "shop.restore.subtitle"))
		restoreLabel.textColor = .white
		restoreLabel.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		
		let restoreContentStackView:UIStackView = .init(arrangedSubviews: [restoreTitleLabel,restoreLabel])
		restoreContentStackView.axis = .vertical
		restoreContentStackView.spacing = UI.Margins/2
		
		let restoreButton:BB_Button = .init(String(key: "shop.restore.button")) { button in
			
			Task {
				
				await MainActor.run {
					
					button?.isLoading = true
				}
				
				let restored = await BB_InAppPurchase.shared.restorePurchases()
				
				button?.isLoading = false
				
				Task { @MainActor in
					
					if restored.contains(BB_InAppPurchase.Identifiers.RemoveAds.rawValue) {
						
						UserDefaults.set(false, .shouldDisplayAds)
						NotificationCenter.post(.updateAds)
						
						UIApplication.feedBack(.Success)
						BB_Sound.shared.playSound(.Success)
						
						let alertController = BB_Alert_ViewController()
						alertController.title = String(key: "shop.restore.success.alert.title")
						alertController.add(String(key: "shop.restore.success.alert.content"))
						alertController.addDismissButton()
						alertController.present()
					}
					else {
						
						BB_Alert_ViewController.present(BB_Error(String(key: "shop.restore.error")))
					}
				}
			}
		}
		restoreButton.type = .secondary
		
		let restoreStackView:UIStackView = .init(arrangedSubviews: [restoreContentStackView,restoreButton])
		restoreStackView.axis = .horizontal
		restoreStackView.spacing = UI.Margins
		restoreStackView.alignment = .center
		restoreStackView.backgroundColor = Colors.Primary
		restoreStackView.layer.cornerRadius = UI.CornerRadius
		restoreStackView.isLayoutMarginsRelativeArrangement = true
		restoreStackView.layoutMargins = .init(horizontal: 1.5*UI.Margins, vertical: UI.Margins)
		
		let stackView:UIStackView = .init(arrangedSubviews: [restoreStackView,tableView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		tableView.showPlaceholder(.Loading)
		
		Task { [weak self] in
			
			self?.products = await BB_InAppPurchase.shared.fetchProducts()
			
			self?.tableView.dismissPlaceholder()
		}
	}
}

extension BB_Shop_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return products?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_Shop_TableViewCell.identifier, for: indexPath) as! BB_Shop_TableViewCell
		cell.product = products?[indexPath.row]
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let product = products?[indexPath.row] {
			
			BB_Alert_ViewController.presentLoading() { alertController in
				
				Task {
					
					let state = await BB_InAppPurchase.shared.purchase(product: product)
					
					alertController?.close {
						
						if state {
							
							if BB_InAppPurchase.Identifiers.allCases.compactMap({ $0.rawValue }).contains(product.id) {
								
								let user:BB_User = .current ?? .init()
								
								if product.id == BB_InAppPurchase.Identifiers.OneDiamond.rawValue {
									
									user.diamonds += 1
								}
								else if product.id == BB_InAppPurchase.Identifiers.FiveDiamond.rawValue {
									
									user.diamonds += 5
								}
								else if product.id == BB_InAppPurchase.Identifiers.TenDiamond.rawValue {
									
									user.diamonds += 10
								}
								
								user.save { error in
									
									if let error {
										
										BB_Alert_ViewController.present(error)
									}
									else {
										
										NotificationCenter.post(.updateUser)
										
										UIApplication.feedBack(.Success)
										BB_Sound.shared.playSound(.Success)
										
										let alertController:BB_Alert_ViewController = .init()
										alertController.title = String(key: "shop.success.alert.title")
										alertController.add(String(key: "shop.success.alert.content"))
										alertController.addDismissButton()
										alertController.present()
									}
								}
							}
						}
						else {
							
							BB_Alert_ViewController.present(BB_Error(String(key: "shop.error")))
						}
					}
				}
			}
		}
	}
}
