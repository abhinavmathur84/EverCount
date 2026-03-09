import GoogleMobileAds
import UIKit

class InterstitialAdHelper: NSObject, ObservableObject {
    private var interstitialAd: GADInterstitialAd?
    private var saveCount = 0
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910" // Replace with real ad unit ID

    override init() {
        super.init()
        loadAd()
    }

    private func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error)")
                return
            }
            self?.interstitialAd = ad
        }
    }

    func recordSaveAndShowIfNeeded() {
        saveCount += 1
        if saveCount % 3 == 0 {
            showAd()
        }
    }

    private func showAd() {
        guard let ad = interstitialAd,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            loadAd()
            return
        }
        ad.present(fromRootViewController: rootViewController)
        loadAd()
    }
}
