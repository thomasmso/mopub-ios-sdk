//
//  MPVASTTrackingTests.m
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAnalyticsTracker.h"
#import "MPVASTTracking.h"
#import "XCTestCase+MPAddition.h"

#pragma mark - MPVASTTracking

@interface MPVASTTracking (Testing)
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;
@end

#pragma mark - MockAnalyticTracker

@interface MockAnalyticTracker : MPAnalyticsTracker

@property (nonatomic, strong) NSArray<NSURL *> *mostRecentlySentURLs;

- (void)reset;

@end

@implementation MockAnalyticTracker

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration {} // no op for this test

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration {} // no op for this test

- (void)sendTrackingRequestForURLs:(NSArray<NSURL *> *)URLs {
    if (self.mostRecentlySentURLs == nil) {
        self.mostRecentlySentURLs = URLs;
    } else {
        self.mostRecentlySentURLs = [self.mostRecentlySentURLs arrayByAddingObjectsFromArray:URLs];
    }
}

- (void)reset {
    self.mostRecentlySentURLs = nil;
}

@end

#pragma mark - MPVASTTrackingTests

@interface MPVASTTrackingTests : XCTestCase
@property (nonatomic, readonly) NSArray<NSString *> *allTrackingEventNames;
@property (nonatomic, readonly) NSSet<MPVideoEvent> *oneOffEventTypes;
@property (nonatomic, readonly) NSDictionary<MPVideoEvent, NSArray<NSString *> *> *testData;
@end

@implementation MPVASTTrackingTests

- (void)setUp {
    if (self.allTrackingEventNames == nil) {
        _allTrackingEventNames = @[MPVideoEventClick,
                                   MPVideoEventCloseLinear,
                                   MPVideoEventCollapse,
                                   MPVideoEventComplete,
                                   MPVideoEventCreativeView,
                                   MPVideoEventError,
                                   MPVideoEventExitFullScreen,
                                   MPVideoEventExpand,
                                   MPVideoEventFirstQuartile,
                                   MPVideoEventFullScreen,
                                   MPVideoEventImpression,
                                   MPVideoEventMidpoint,
                                   MPVideoEventMute,
                                   MPVideoEventPause,
                                   MPVideoEventProgress,
                                   MPVideoEventResume,
                                   MPVideoEventSkip,
                                   MPVideoEventStart,
                                   MPVideoEventThirdQuartile,
                                   MPVideoEventUnmute];
    }

    if (self.testData == nil) {
        _testData = @{MPVideoEventClick: @[@"https://www.mopub.com/?q=videoClickTracking"],
                      MPVideoEventCloseLinear: @[@"https://www.mopub.com/?q=closeLinear"],
                      MPVideoEventCollapse: @[@"https://www.mopub.com/?q=collapse"],
                      MPVideoEventComplete: @[@"https://www.mopub.com/?q=complete"],
                      MPVideoEventCreativeView: @[@"https://www.mopub.com/?q=creativeView"],
                      MPVideoEventError: @[@"https://www.mopub.com/?q=error&errorcode=%5BERRORCODE%5D"],
                      MPVideoEventExitFullScreen: @[@"https://www.mopub.com/?q=exitFullscreen"],
                      MPVideoEventExpand: @[@"https://www.mopub.com/?q=expand"],
                      MPVideoEventFirstQuartile: @[@"https://www.mopub.com/?q=firstQuartile"],
                      MPVideoEventFullScreen: @[@"https://www.mopub.com/?q=fullscreen"],
                      MPVideoEventImpression: @[@"https://www.mopub.com/?q=impression",
                                                @"https://www.mopub.com/?q=impression1",
                                                @"https://www.mopub.com/?q=impression2",
                                                @"https://www.mopub.com/?q=impression3"],
                      MPVideoEventMidpoint: @[@"https://www.mopub.com/?q=midpoint"],
                      MPVideoEventMute: @[@"https://www.mopub.com/?q=mute"],
                      MPVideoEventPause: @[@"https://www.mopub.com/?q=pause"],
                      MPVideoEventProgress: @[@"https://www.mopub.com/?q=progress00",
                                              @"https://www.mopub.com/?q=progress05",
                                              @"https://www.mopub.com/?q=progress10",
                                              @"https://www.mopub.com/?q=progress15",
                                              @"https://www.mopub.com/?q=progress20",
                                              @"https://www.mopub.com/?q=progress25",
                                              @"https://www.mopub.com/?q=progress30"],
                      MPVideoEventResume: @[@"https://www.mopub.com/?q=resume"],
                      MPVideoEventSkip: @[@"https://www.mopub.com/?q=skip"],
                      MPVideoEventStart: @[@"https://www.mopub.com/?q=start",
                                           @"https://www.mopub.com/?q=start1"],
                      MPVideoEventThirdQuartile: @[@"https://www.mopub.com/?q=thirdQuartile"],
                      MPVideoEventUnmute: @[@"https://www.mopub.com/?q=unmute"]};
    }

    if (self.oneOffEventTypes == nil) {
        _oneOffEventTypes = [NSSet setWithObjects:
                             MPVideoEventClick,
                             MPVideoEventCloseLinear,
                             MPVideoEventComplete,
                             MPVideoEventCreativeView,
                             MPVideoEventFirstQuartile,
                             MPVideoEventImpression,
                             MPVideoEventMidpoint,
                             MPVideoEventProgress,
                             MPVideoEventSkip,
                             MPVideoEventStart,
                             MPVideoEventThirdQuartile,
                             nil];
    }
}

- (MPVASTTracking *)makeTestSubject {
    MPVASTResponse *vastResponse = [self vastResponseFromXMLFile:@"VAST_3.0_linear_ad_comprehensive"];
    MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:vastResponse additionalTrackers:nil];
    MPVASTTracking *testSubject = [[MPVASTTracking alloc] initWithVideoConfig:videoConfig
                                                              videoURL:[NSURL URLWithString:@"https://any.thing"]];;
    testSubject.analyticsTracker = [MockAnalyticTracker new];
    return testSubject;
}

/**
 Test the `handleVideoEvent:videoTimeOffset:` method.
 */
- (void)testHandlingEvents {
    MPVASTTracking *testSubject = [self makeTestSubject];
    for (NSString *eventName in self.allTrackingEventNames) {
        [testSubject handleVideoEvent:eventName videoTimeOffset:5]; // time offset does not matter
        NSArray<NSURL *> *urls = [(MockAnalyticTracker *)testSubject.analyticsTracker mostRecentlySentURLs];

        if ([eventName isEqualToString:MPVideoEventProgress]) {
            // nothing should happen since this should be handled by `handleVideoProgressEvent:videoDuration:`
            XCTAssertEqual(urls.count, 0);
        } else {
            if (urls.count != self.testData[eventName].count) {
                XCTFail(@"[%@] URL count %lu is not equal to expected %lu",
                        eventName, urls.count, self.testData[eventName].count);
            }
        }
        [(MockAnalyticTracker *)testSubject.analyticsTracker reset];
    }

    // This loop fires all events again, and verify the one-off events are sent only once.
    for (NSString *eventName in self.allTrackingEventNames) {
        [testSubject handleVideoEvent:eventName videoTimeOffset:5]; // time offset does not matter
        NSArray<NSURL *> *urls = [(MockAnalyticTracker *)testSubject.analyticsTracker mostRecentlySentURLs];

        if ([self.oneOffEventTypes containsObject:eventName] == NO) {
            if (urls.count != self.testData[eventName].count) {
                XCTFail(@"[%@] URL count %lu is not equal to expected %lu",
                        eventName, urls.count, self.testData[eventName].count);
            }
        } else {
            XCTAssertEqual(urls.count, 0);
        }
        [(MockAnalyticTracker *)testSubject.analyticsTracker reset];
    }
}

/**
 Test the `handleVideoProgressEvent:videoDuration:` method.
 */
- (void)testHandlingProgressEvents {
    MPVASTTracking *testSubject = [self makeTestSubject];
    NSArray<NSNumber *> *times = @[@0, @5, @10, @15, @20, @25, @30]; // defined in the original XML

    for (int i = 0; i < times.count; i++) {
        [testSubject handleVideoProgressEvent:times[i].doubleValue videoDuration:30];
        NSArray<NSURL *> *urls = [(MockAnalyticTracker *)testSubject.analyticsTracker mostRecentlySentURLs];
        if (times[i].intValue == 0) {
            XCTAssertEqual(urls.count, 3);
            XCTAssertTrue([urls[0].absoluteString isEqualToString:self.testData[MPVideoEventStart][0]]);
            XCTAssertTrue([urls[1].absoluteString isEqualToString:self.testData[MPVideoEventStart][1]]);
            XCTAssertTrue([urls[2].absoluteString isEqualToString:self.testData[MPVideoEventProgress][i]]);
        } else if (times[i].intValue == 10) {
            XCTAssertEqual(urls.count, 2);
            XCTAssertTrue([urls[0].absoluteString isEqualToString:self.testData[MPVideoEventFirstQuartile][0]]);
            XCTAssertTrue([urls[1].absoluteString isEqualToString:self.testData[MPVideoEventProgress][i]]);
        } else if (times[i].intValue == 15) {
            XCTAssertEqual(urls.count, 2);
            XCTAssertTrue([urls[0].absoluteString isEqualToString:self.testData[MPVideoEventMidpoint][0]]);
            XCTAssertTrue([urls[1].absoluteString isEqualToString:self.testData[MPVideoEventProgress][i]]);
        } else if (times[i].intValue == 25) {
            XCTAssertEqual(urls.count, 2);
            XCTAssertTrue([urls[0].absoluteString isEqualToString:self.testData[MPVideoEventThirdQuartile][0]]);
            XCTAssertTrue([urls[1].absoluteString isEqualToString:self.testData[MPVideoEventProgress][i]]);
        } else {
            XCTAssertEqual(urls.count, 1);
            XCTAssertTrue([urls[0].absoluteString isEqualToString:self.testData[MPVideoEventProgress][i]]);
        }
        [(MockAnalyticTracker *)testSubject.analyticsTracker reset];
    }

    // This loop fires all progress events again, and verify they are sent only once.
    for (int i = 0; i < times.count; i++) {
        [testSubject handleVideoProgressEvent:times[i].doubleValue videoDuration:30];
        NSArray<NSURL *> *urls = [(MockAnalyticTracker *)testSubject.analyticsTracker mostRecentlySentURLs];
        XCTAssertEqual(urls.count, 0);
    }
}

@end
