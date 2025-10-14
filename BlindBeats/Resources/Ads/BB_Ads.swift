//
//  BB_Ads.swift
//  BlindBeats
//
//  Created by BLIN Michael on 08/06/2024.
//

import Foundation
import GoogleMobileAds

public class BB_Ads : NSObject {
	
	public struct Identifiers {
		
		public struct FullScreen {
			
			static let AppOpening:String = "ca-app-pub-9540216894729209/4530883007"
			
			public struct Game {
				
				public struct Solo {
					
					static let Start:String = "ca-app-pub-9540216894729209/6315588020"
					static let End:String = "ca-app-pub-9540216894729209/4615477638"
				}
			}
		}
		
		public struct Banner {
			
			static let Home:String = "ca-app-pub-9540216894729209/9894890323"
			static let Playlists:String = "ca-app-pub-9540216894729209/2823776018"
		}
	}
	
	public static let shared:BB_Ads = .init()
	
	private var appOpening:AppOpenAd?
	private var appOpeningDismissCompletion:(()->Void)?
	
	private var rewardedAdReward:AdReward?
	private var rewardedAdCompletion:((Bool,Bool?)->Void)?
	private var rewardedAd: RewardedAd?
	
	private var interstitialPresentCompletion:(()->Void)?
	private var interstitialDismissCompletion:(()->Void)?
	
	public var shouldDisplayAd:Bool {
		
		return (UserDefaults.get(.shouldDisplayAds) as? Bool ?? true) && BB_CMP.shared.isConsentObtained && !UIApplication.isDebug
	}
	
	public func start() {
		
		if UIApplication.isDebug {
			
			MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "1f2555cdf1d612b496f90d12141ab12d" ]
		}
		
		MobileAds.shared.start(completionHandler: nil)
	}
	
	public func presentAppOpening(_ dismissCompletion:(()->Void)? = nil) {
		
		if shouldDisplayAd {
			
			appOpeningDismissCompletion = dismissCompletion
			
			AppOpenAd.load(with: Identifiers.FullScreen.AppOpening, request: Request()) { [weak self] ad, error in
				
				self?.appOpening = ad
				self?.appOpening?.fullScreenContentDelegate = self
				self?.appOpening?.present(from: UI.MainController)
			}
		}
		else {
			
			dismissCompletion?()
		}
	}
	
	public func presentInterstitial(_ identifier:String, _ presentCompletion:(()->Void)? = nil, _ dismissCompletion:(()->Void)? = nil) {
		
		if shouldDisplayAd {
			
			interstitialPresentCompletion = presentCompletion
			interstitialDismissCompletion = dismissCompletion
			
			InterstitialAd.load(with:identifier, request: Request(), completionHandler: { [weak self] ad, _ in
				
				if let ad {
					
					ad.fullScreenContentDelegate = self
					ad.present(from: UI.MainController)
				}
				else {
					
					dismissCompletion?()
				}
			})
		}
		else {
			
			dismissCompletion?()
		}
	}
	
	public func presentRewardedAd(_ identifier:String, _ completion:((_ state:Bool, _ exception:Bool?)->Void)?) async {
		
		rewardedAdCompletion = completion
		
		do {
			
			rewardedAd = try await RewardedAd.load(with: identifier, request: Request())
			rewardedAd?.fullScreenContentDelegate = self
			
			if let ad = rewardedAd {
				
				await ad.present(from: nil) { [weak self] in
					
					self?.rewardedAdReward = self?.rewardedAd?.adReward
				}
			}
		}
		catch {
			
			rewardedAdCompletion?(false,(error as NSError).code == 1)
			rewardedAdCompletion = nil
		}
	}
	
	public func presentBanner(_ identifier:String, _ rootViewController:UIViewController) -> BannerView {
		
		let bannerView:BannerView = .init(adSize: AdSizeBanner)
		bannerView.adUnitID = identifier
		bannerView.rootViewController = rootViewController
		bannerView.delegate = self
		
		if shouldDisplayAd {
			
			bannerView.load(Request())
		}
		
		return bannerView
	}
}

extension BB_Ads : FullScreenContentDelegate {
	
	public func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
		
		if ad is InterstitialAd {
			
			interstitialPresentCompletion?()
			interstitialPresentCompletion = nil
		}
	}
	
	public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
		
		appOpening = nil
		
		if rewardedAd != nil && rewardedAdCompletion != nil && ad is RewardedAd {
			
			rewardedAdCompletion?(true,nil)
			
			rewardedAd = nil
			rewardedAdCompletion = nil
			rewardedAdReward = nil
		}
		else if ad is InterstitialAd {
			
			interstitialDismissCompletion?()
			interstitialDismissCompletion = nil
		}
		else if ad is AppOpenAd {
			
			appOpeningDismissCompletion?()
			appOpeningDismissCompletion = nil
		}
	}
	
	public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
		
		if ad is InterstitialAd {
			
			interstitialDismissCompletion?()
			interstitialDismissCompletion = nil
		}
		else if rewardedAd != nil && rewardedAdCompletion != nil && ad is RewardedAd {
			
			rewardedAdCompletion?(false,nil)
			
			rewardedAd = nil
			rewardedAdCompletion = nil
			rewardedAdReward = nil
		}
		else if ad is AppOpenAd {
			
			appOpeningDismissCompletion?()
			appOpeningDismissCompletion = nil
		}
	}
}


extension BB_Ads : BannerViewDelegate {
	
	public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
		
		UIView.animation {
			
			bannerView.isHidden = true
			bannerView.alpha = bannerView.isHidden ? 0.0 : 1.0
			bannerView.superview?.layoutIfNeeded()
		}
	}
}

extension BannerView {
	
	open override func didMoveToSuperview() {
		
		super.didMoveToSuperview()
		
		NotificationCenter.add(.updateAds) { [weak self] _ in
											  
			self?.isHidden = !BB_Ads.shared.shouldDisplayAd
			self?.refresh()
		}
	}
	
	public func refresh() {
		
		if !isHidden {
			
			load(Request())
		}
	}
}
