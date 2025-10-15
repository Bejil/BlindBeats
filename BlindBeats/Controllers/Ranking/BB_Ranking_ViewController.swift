//
//  BB_Ranking_ViewController.swift
//  BlindBeats
//
//  Created by BLIN Michael on 15/10/2025.
//

import UIKit

public class BB_Ranking_ViewController : BB_ViewController {
	
	private var users:[BB_User]? {
		
		didSet {
			
			tableView.dismissPlaceholder()
			
			if users?.isEmpty ?? true {
				
				tableView.showPlaceholder(.Empty)
			}
			
			tableView.reloadData()
			
			tableView.scrollToRow(at: .init(row: users?.firstIndex(where: { $0 == BB_User.current }) ?? 0, section: 0), at: .middle, animated: true)
		}
	}
	private lazy var tableView: BB_TableView = {
		
		$0.delegate = self
		$0.dataSource = self
		$0.register(BB_User_TableViewCell.self, forCellReuseIdentifier: BB_User_TableViewCell.identifier)
		$0.separatorStyle = .none
		$0.backgroundView = nil
		return $0
		
	}(BB_TableView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: "ranking.title")
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		fetchUsers()
	}
	
	private func fetchUsers() {
		
		tableView.showPlaceholder(.Loading)
		
		BB_User.get { [weak self] error, users in
			
			self?.tableView.dismissPlaceholder()
			
			if let error {
				
				self?.tableView.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.fetchUsers()
				}
			}
			
			self?.users = users
		}
	}
}

extension BB_Ranking_ViewController: UITableViewDataSource, UITableViewDelegate {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return users?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let user = users?[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BB_User_TableViewCell.identifier, for: indexPath) as! BB_User_TableViewCell
		cell.rank = indexPath.row + 1
		cell.user = user
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let viewController:BB_Playlists_ViewController = .init()
		viewController.user = users?[indexPath.row]
		UI.MainController.navigationController?.pushViewController(viewController, animated: true)
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		
		let alertController:BB_User_Infos_Alert_ViewController = .init()
		alertController.user = users?[indexPath.row]
		alertController.present()
	}
}
