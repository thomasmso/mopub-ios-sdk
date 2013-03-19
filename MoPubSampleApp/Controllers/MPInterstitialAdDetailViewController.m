//
//  MPInterstitialAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"

@interface MPInterstitialAdDetailViewController ()

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPInterstitialAdController *interstitial;

@end

@implementation MPInterstitialAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)adInfo
{
    self = [super init];
    if (self) {
        self.info = adInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Interstitial";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.showButton.hidden = YES;

    self.interstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.info.ID];
    self.interstitial.delegate = self;

    [super viewDidLoad];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.interstitial loadAd];
    [self.spinner startAnimating];
    self.showButton.hidden = YES;
    self.loadButton.enabled = NO;
}

- (IBAction)didTapShowButton:(id)sender
{
    [self.interstitial showFromViewController:self];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.spinner stopAnimating];
    self.showButton.hidden = NO;
    self.loadButton.enabled = YES;
}

@end