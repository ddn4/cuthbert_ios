//
//  CuthbertJuxtapositionMonitor.h
//  Cuthbert
//
//  Created by Dan Nemeth on 7/7/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PositionRepo.h"

@protocol JuxtapositionDelegate <NSObject>

- (void) locationUpdated: (CLLocation *)currentLocation fromLocation: (CLLocation *)previousLocation;

@end

@interface CuthbertJuxtapositionMonitor : NSObject <CLLocationManagerDelegate> {
    UIBackgroundTaskIdentifier backgroundTask;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *userAPIToken;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) PositionRepo *positionRepo;
@property (nonatomic) BOOL serviceAvailable;

+ (CuthbertJuxtapositionMonitor *)sharedMonitor;
- (void)initTimer;
- (void)startLocationServices;
- (void)stopLocationServices;

@end
