//
//  MOPUBExperimentProviderTests.m
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration+Testing.h"
#import "MOPUBExperimentProvider.h"
#import "MoPub.h"
#import "MPAdConfiguration.h"
#import "MOPUBExperimentProvider+Testing.h"

@interface MOPUBExperimentProviderTests : XCTestCase

@end

@implementation MOPUBExperimentProviderTests

- (void)testClickthroughExperimentDefault {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:nil data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentInApp {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentNativeBrowser {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

- (void)testClickthroughExperimentSafariViewController {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);
}

- (void)testClickthroughClientOverride {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];

    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);

    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);

    // Display agent type is overridden to MOPUBDisplayAgentTypeSafariViewController
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeSafariViewController];
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);

    // Display agent type is overridden to MOPUBDisplayAgentTypeNativeSafari
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

@end
