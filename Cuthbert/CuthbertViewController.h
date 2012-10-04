//
//  CuthbertViewController.h
//  Cuthbert
//
//  Created by Dan Nemeth on 7/4/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuthbertJuxtapositionMonitor.h"

@interface CuthbertViewController : UIViewController <JuxtapositionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cTime;
@property (weak, nonatomic) IBOutlet UILabel *cLatitude;
@property (weak, nonatomic) IBOutlet UILabel *cLongitude;
@property (weak, nonatomic) IBOutlet UILabel *pTime;
@property (weak, nonatomic) IBOutlet UILabel *pLatitude;
@property (weak, nonatomic) IBOutlet UILabel *pLongitude;
@property (weak, nonatomic) CuthbertJuxtapositionMonitor *monitor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userControl;


- (void) locationUpdated: (CLLocation *)currentLocation fromLocation: (CLLocation *)previousLocation;

@end
