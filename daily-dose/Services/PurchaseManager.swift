//
//  PurchaseManager.swift
//  daily-dose
//
//  Created by faisal badran on 2020-05-06.
//  Copyright © 2020 faisal badran. All rights reserved.
//

import Foundation
import StoreKit

typealias CompletionHandler = (_ success: Bool) -> ()

class PurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    static let instance = PurchaseManager()
    
    let IAP_REMOVE_ADS = "com.faisal.dailydose.remove.ads"
    
    var productsRequest: SKProductsRequest!
    var products = [SKProduct]()
    var transactionComplete: CompletionHandler?
    
    func fetchProducts() {
        let productIds = NSSet(object: IAP_REMOVE_ADS) as! Set<String>
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func purchaseRemoveAds(onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() && products.count > 0 {
            transactionComplete = onComplete
            let removeAdsProduct = products[0]
            let payment = SKPayment(product: removeAdsProduct)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            onComplete(false)
        }
    }
    
    func restorePurchases(onComplete: @escaping CompletionHandler) {
        if SKPaymentQueue.canMakePayments() {
            transactionComplete = onComplete
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            onComplete(false)
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            products = response.products
        }
        
        for invalidId in response.invalidProductIdentifiers {
            print(invalidId)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                    //Remove ads
                    UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                    transactionComplete?(true)
                }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionComplete?(false)
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                if transaction.payment.productIdentifier == IAP_REMOVE_ADS {
                    UserDefaults.standard.set(true, forKey: IAP_REMOVE_ADS)
                }
                transactionComplete?(true)
                break
            default:
                transactionComplete?(false)
                break
            }
        }
    }
}
