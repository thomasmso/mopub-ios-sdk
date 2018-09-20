//
//  MPMockBannerCustomEvent.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEvent.h"

@interface MPMockBannerCustomEvent : MPBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
