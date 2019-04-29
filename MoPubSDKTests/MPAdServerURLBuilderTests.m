//
//  MPAdServerURLBuilderTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAdServerURLBuilder+Testing.h"
#import "MPAPIEndpoints.h"
#import "MPConsentManager.h"
#import "MPIdentityProvider.h"
#import "MPMediationManager.h"
#import "MPMediationManager+Testing.h"
#import "MPURL.h"
#import "MPViewabilityTracker.h"
#import "NSString+MPConsentStatus.h"
#import "NSString+MPAdditions.h"
#import "NSURLComponents+Testing.h"
#import "MPRateLimitManager.h"

static NSString * const kTestAdUnitId = @"";
static NSString * const kTestKeywords = @"";
static NSString * const kGDPRAppliesStorageKey                   = @"com.mopub.mopub-ios-sdk.gdpr.applies";
static NSString * const kConsentedIabVendorListStorageKey        = @"com.mopub.mopub-ios-sdk.consented.iab.vendor.list";
static NSString * const kConsentedPrivacyPolicyVersionStorageKey = @"com.mopub.mopub-ios-sdk.consented.privacy.policy.version";
static NSString * const kConsentedVendorListVersionStorageKey    = @"com.mopub.mopub-ios-sdk.consented.vendor.list.version";
static NSString * const kLastChangedMsStorageKey                 = @"com.mopub.mopub-ios-sdk.last.changed.ms";

@interface MPAdServerURLBuilderTests : XCTestCase

@end

@implementation MPAdServerURLBuilderTests

- (void)setUp {
    // Reset viewability
    [MPViewabilityTracker initialize];

    NSUserDefaults * defaults = NSUserDefaults.standardUserDefaults;
    [defaults setInteger:MPBoolYes forKey:kGDPRAppliesStorageKey];
    [defaults setObject:nil forKey:kConsentedIabVendorListStorageKey];
    [defaults setObject:nil forKey:kConsentedPrivacyPolicyVersionStorageKey];
    [defaults setObject:nil forKey:kConsentedVendorListVersionStorageKey];
    [defaults setObject:nil forKey:kLastChangedMsStorageKey];
    [defaults synchronize];
}

#pragma mark - Viewability

- (void)testViewabilityPresentInPOSTData {
    // By default, IAS should be enabled
    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords userDataKeywords:nil location:nil];
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}

- (void)testViewabilityDisabled {
    // By default, IAS should be enabled so we should disable all vendors
    [MPViewabilityTracker disableViewability:(MPViewabilityOptionIAS | MPViewabilityOptionMoat)];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords userDataKeywords:nil location:nil];
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertTrue([viewabilityValue isEqualToString:@"0"]);
}

#pragma mark - Advanced Bidding

- (void)testAdvancedBiddingNotInitialized {
    MPMediationManager.sharedManager.adapters = [NSMutableDictionary dictionary];
    NSDictionary * queryParam = [MPAdServerURLBuilder adapterInformation];
    XCTAssertNil(queryParam);

    NSString * tokens = [MPAdServerURLBuilder advancedBiddingValue];
    XCTAssertNil(tokens);
}

#pragma mark - Open Endpoint

- (void)testExpectedPOSTParamsSessionTracking {
    MPURL * url = [MPAdServerURLBuilder sessionTrackingURL];

    // Check for session tracking parameter
    NSString * sessionValue = [url stringForPOSTDataKey:kOpenEndpointSessionTrackingKey];
    XCTAssert([sessionValue isEqualToString:@"1"]);

    // Check for IDFA
    NSString * idfaValue = [url stringForPOSTDataKey:kIdfaKey];
    XCTAssertNotNil(idfaValue);

    // Check for SDK version
    NSString * versionValue = [url stringForPOSTDataKey:kSDKVersionKey];
    XCTAssertNotNil(versionValue);

    // Check for current consent status
    NSString * consentValue = [url stringForPOSTDataKey:kCurrentConsentStatusKey];
    XCTAssertNotNil(consentValue);
}

- (void)testExpectedPOSTParamsConversionTracking {
    NSString * appID = @"0123456789";
    MPURL * url = [MPAdServerURLBuilder conversionTrackingURLForAppID:appID];

    // Check for lack of session tracking parameter
    NSString * sessionValue = [url stringForPOSTDataKey:kOpenEndpointSessionTrackingKey];
    XCTAssertNil(sessionValue);

    // Check for IDFA
    NSString * idfaValue = [url stringForPOSTDataKey:kIdfaKey];
    XCTAssertNotNil(idfaValue);

    // Check for ID
    NSString * idValue = [url stringForPOSTDataKey:kAdServerIDKey];
    XCTAssert([idValue isEqualToString:appID]);

    // Check for SDK version
    NSString * versionValue = [url stringForPOSTDataKey:kSDKVersionKey];
    XCTAssertNotNil(versionValue);

    // Check for current consent status
    NSString * consentValue = [url stringForPOSTDataKey:kCurrentConsentStatusKey];
    XCTAssertNotNil(consentValue);
}

#pragma mark - Consent

- (void)testConsentStatusInAdRequest {
    NSString * consentStatus = [NSString stringFromConsentStatus:MPConsentManager.sharedManager.currentStatus];
    XCTAssertNotNil(consentStatus);

    MPURL * request = [MPAdServerURLBuilder URLWithAdUnitID:@"1234" keywords:nil userDataKeywords:nil location:nil];
    XCTAssertNotNil(request);

    NSString * consentValue = [request stringForPOSTDataKey:kCurrentConsentStatusKey];
    NSString * gdprAppliesValue = [request stringForPOSTDataKey:kGDPRAppliesKey];

    XCTAssert([consentValue isEqualToString:consentStatus]);
    XCTAssert([gdprAppliesValue isEqualToString:@"1"]);
}

- (void)testNilLastChangedMs {
    // Nil out last changed ms field
    [NSUserDefaults.standardUserDefaults setObject:nil forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testNegativeLastChangedMs {
    // Set negative value for last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:(-200000) forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testZeroLastChangedMs {
    // Zero out last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:0 forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testInvalidLastChangedMs {
    // Set invalid last changed ms field
    [NSUserDefaults.standardUserDefaults setObject:@"" forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssertNil(lastChangeValue);
}

- (void)testValidLastChangedMs {
    // Set valid last changed ms field
    [NSUserDefaults.standardUserDefaults setDouble:1532021932 forKey:kLastChangedMsStorageKey];

    MPURL * url = [MPAdServerURLBuilder consentSynchronizationUrl];
    XCTAssertNotNil(url);

    NSString * lastChangeValue = [url stringForPOSTDataKey:kLastChangedMsKey];
    XCTAssert([lastChangeValue isEqualToString:@"1532021932"]);
}

#pragma mark - URL String Parsing

- (NSString *)queryParameterValueForKey:(NSString *)key inUrl:(NSString *)url {
    NSString * prefix = [NSString stringWithFormat:@"%@=", key];

    // Extract the query parameter using string parsing instead of
    // using `NSURLComponents` and `NSURLQueryItem` since they automatically decode
    // query item values.
    NSString * queryItemPair = [[url componentsSeparatedByString:@"&"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString * component = (NSString *)evaluatedObject;
        return [component hasPrefix:prefix];
    }]].firstObject;

    NSString * value = [queryItemPair componentsSeparatedByString:@"="][1];
    return value;
}

#pragma mark - Rate Limiting

- (void)testFilledReasonWithNonZeroRateLimitValue {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:10 reason:@"Reason"];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit"
                                               keywords:nil
                                       userDataKeywords:nil
                                               location:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertEqual([value integerValue], 10);
    XCTAssert([[url stringForPOSTDataKey:kBackoffReasonKey] isEqualToString:@"Reason"]);
}

- (void)testZeroRateLimitValueDoesntShow {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:0 reason:nil];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit"
                                               keywords:nil
                                       userDataKeywords:nil
                                               location:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertNil(value);
    XCTAssertNil([url stringForPOSTDataKey:kBackoffReasonKey]);
}

- (void)testNilReasonWithNonZeroRateLimitValue {
    [[MPRateLimitManager sharedInstance] setRateLimitTimerWithAdUnitId:@"fake_adunit" milliseconds:10 reason:nil];

    MPURL * url = [MPAdServerURLBuilder URLWithAdUnitID:@"fake_adunit"
                                               keywords:nil
                                       userDataKeywords:nil
                                               location:nil];

    NSNumber * value = [url numberForPOSTDataKey:kBackoffMsKey];
    XCTAssertEqual([value integerValue], 10);
    XCTAssertNil([url stringForPOSTDataKey:kBackoffReasonKey]);
}

@end
