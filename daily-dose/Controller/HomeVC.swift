//
//  ViewController.swift
//  daily-dose
//
//  Created by faisal badran on 2020-05-05.
//  Copyright © 2020 faisal badran. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HomeVC: UIViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var removeAdsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAds()
        
    }
    
    func setupAds() {
        if UserDefaults.standard.bool(forKey: PurchaseManager.instance.IAP_REMOVE_ADS) {
            removeAdsButton.removeFromSuperview()
            bannerView.removeFromSuperview()
        } else {
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    
    @IBAction func restoreBtnPressed(_ sender: Any) {
        PurchaseManager.instance.restorePurchases { success in
            if success {
                self.setupAds()
            }
        }
    }
    
    @IBAction func removeAdsPressed(_ sender: Any) {
        // Show a loading spinner ActivityIndicator
        PurchaseManager.instance.purchaseRemoveAds { success in
            // Dismiss spinner
            if success {
                self.removeAdsButton.removeFromSuperview()
                self.bannerView.removeFromSuperview()
            } else {
                // Show message to the user why it failed
            }
        }
    }
    
}

