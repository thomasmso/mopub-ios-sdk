//
//  MPInterstitialAdManagerDelegateHandler.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPInterstitialAdManagerDelegateHandler.h"

@implementation MPInterstitialAdManagerDelegateHandler

- (void)managerDidLoadInterstitial:(MPInterstitialAdManager *)manager {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)manager:(MPInterstitialAdManager *)manager didFailToLoadInterstitialWithError:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(error); }
}

- (void)managerWillPresentInterstitial:(MPInterstitialAdManager *)manager {
    if (self.willPresent != nil) { self.willPresent(); }
}

- (void)managerDidPresentInterstitial:(MPInterstitialAdManager *)manager {
    if (self.didPresent != nil) { self.didPresent(); }
}

- (void)managerWillDismissInterstitial:(MPInterstitialAdManager *)manager {
    if (self.willDismiss != nil) { self.willDismiss(); }
}

- (void)managerDidDismissInterstitial:(MPInterstitialAdManager *)manager {
    if (self.didDismiss != nil) { self.didDismiss(); }
}

- (void)managerDidExpireInterstitial:(MPInterstitialAdManager *)manager {
    if (self.didExpire != nil) { self.didExpire(); }
}

- (void)managerDidReceiveTapEventFromInterstitial:(MPInterstitialAdManager *)manager {
    if (self.didTap != nil) { self.didTap(); }
}

@end
