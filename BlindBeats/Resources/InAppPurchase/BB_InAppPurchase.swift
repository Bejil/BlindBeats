//
//  BB_InAppPurchase.swift
//  BlinBeats
//
//  Created by BLIN Michael on 10/03/2025.
//

import StoreKit
import SwiftUI

@MainActor
final class BB_InAppPurchase: ObservableObject {
	
	public enum Identifiers:String, CaseIterable {
		
		case RemoveAds = "com.michaelblin.BlindBeats.removeAds"
		case OneDiamond = "com.michaelblin.BlindBeats.oneDiamond"
		case FiveDiamond = "com.michaelblin.BlindBeats.fiveDiamonds"
		case TenDiamond = "com.michaelblin.BlindBeats.tenDiamonds"
	}
	
	static let shared = BB_InAppPurchase()
	
	public func fetchProducts() async -> [Product] {
		
		do {
			
			let storeProducts = try await Product.products(for: Identifiers.allCases.compactMap({ $0.rawValue }))
			
			let sortedProducts = storeProducts.sorted { product1, product2 in
				
				guard let index1 = Identifiers.allCases.firstIndex(where: { $0.rawValue == product1.id }),
					  let index2 = Identifiers.allCases.firstIndex(where: { $0.rawValue == product2.id }) else {
					return false
				}
				return index1 < index2
			}
			
			return sortedProducts
		}
		catch {
			
			return []
		}
	}
	
	public func purchase(product: Product) async -> Bool {
		
		do {
			
			let result = try await product.purchase()
			
			switch result {
				
				case .success(_):
					return true
				case .userCancelled, .pending:
					return false
				@unknown default:
					return false
			}
		}
		catch {
			
			return false
		}
	}
	
	public func restorePurchases() async -> [String] {
		
		var restoredProductIDs: [String] = []
		
		do {
			
			for await result in Transaction.currentEntitlements {
				
				let transaction = try checkVerified(result)
				restoredProductIDs.append(transaction.productID)
			}
			
			return restoredProductIDs
		}
		catch {
			
			return []
		}
	}
	
	private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		
		switch result {
			
			case .verified(let signedType):
				return signedType
			case .unverified(_, let error):
				throw error
		}
	}
}
