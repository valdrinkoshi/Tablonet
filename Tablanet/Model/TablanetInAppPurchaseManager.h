//
//  TablanetInAppPurchaseManager.h
//  Tablanet
//
//  Created by Valdrin on 13/09/12.
//  Copyright (c) 2012 Sap Business Objects Research Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseManagerTransactionCancelledNotification @"kInAppPurchaseManagerTransactionCancelledNotification"


@interface TablanetInAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
+(TablanetInAppPurchaseManager*)singleton;
+(void)destroy;
@end
