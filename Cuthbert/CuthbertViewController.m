//
//  CuthbertViewController.m
//  Cuthbert
//
//  Created by Dan Nemeth on 7/4/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import "CuthbertViewController.h"
#import "CuthbertJuxtapositionMonitor.h"

@interface CuthbertViewController ()

@end

@implementation CuthbertViewController
@synthesize cTime = _cTime;
@synthesize cLatitude = _cLatitude;
@synthesize cLongitude = _cLongitude;
@synthesize pTime = _pTime;
@synthesize pLatitude = _pLatitude;
@synthesize pLongitude = _pLongitude;
@synthesize monitor = _monitor;
@synthesize userControl = _userControl;

- (IBAction)userButtonPressed:(UISegmentedControl *)sender {
    if ([sender selectedSegmentIndex] == 0)
        self.monitor.userAPIToken = @"50295f2e8822700200000002";
    else {
        self.monitor.userAPIToken = @"50295f268822700200000001";
    }
}

- (CuthbertJuxtapositionMonitor *) monitor {
   if (!_monitor) {
        _monitor = [CuthbertJuxtapositionMonitor sharedMonitor];   
    }
    return _monitor;
}

- (void) locationUpdated: (CLLocation *)currentLocation fromLocation:(CLLocation *)previousLocation {
    self.pTime.text = [previousLocation.timestamp description];
    self.pLatitude.text = [NSString stringWithFormat: @"%g", previousLocation.coordinate.latitude];
    self.pLongitude.text = [NSString stringWithFormat:@"%g", previousLocation.coordinate.longitude];
    self.cTime.text = [currentLocation.timestamp description];    
    self.cLatitude.text = [NSString stringWithFormat: @"%g", currentLocation.coordinate.latitude];
    self.cLongitude.text = [NSString stringWithFormat:@"%g", currentLocation.coordinate.longitude];
}

- (void) viewDidLoad {
    self.monitor.delegate = self;
    [self.monitor startLocationServices];
}
- (void)viewDidUnload {
    [self setUserControl:nil];
    [super viewDidUnload];
}
@end
