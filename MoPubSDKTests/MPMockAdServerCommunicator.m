//
//  MPMockAdServerCommunicator.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMockAdServerCommunicator.h"

@implementation MPMockAdServerCommunicator

- (void)loadURL:(NSURL *)URL {
    self.lastUrlLoaded = URL;

    NSArray<MPAdConfiguration *> * configurations = self.mockConfigurationsResponse;
    if (self.loadMockResponsesOnce) {
        self.mockConfigurationsResponse = nil;
    }

    if ([self.delegate respondsToSelector:@selector(communicatorDidReceiveAdConfigurations:)]) {
        [self.delegate communicatorDidReceiveAdConfigurations:configurations];
    }
}

- (void)sendBeforeLoadUrlWithConfiguration:(MPAdConfiguration *)configuration
{
    self.numberOfBeforeLoadEventsFired++;
}

- (void)sendAfterLoadUrlWithConfiguration:(MPAdConfiguration *)configuration
                      adapterLoadDuration:(NSTimeInterval)duration
                        adapterLoadResult:(MPAfterLoadResult)result
{
    self.numberOfAfterLoadEventsFired++;
    self.lastAfterLoadResultWasTimeout = (result == MPAfterLoadResultTimeout);
}

@end
