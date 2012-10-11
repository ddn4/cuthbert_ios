//
//  CuthbertJuxtapositionMonitor.m
//  Cuthbert
//
//  Created by Dan Nemeth on 7/7/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import "CuthbertJuxtapositionMonitor.h"
#import "AFNetworking.h"
#import "CuthbertJuxtapositionAPIClient.h"

@implementation CuthbertJuxtapositionMonitor 

@synthesize locationManager = _locationManager;
@synthesize delegate = _delegate;
@synthesize timer = _timer;
@synthesize timerDuration = _timerDuration;
@synthesize userAPIToken = _userAPIToken;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize positionRepo = _positionRepo;
@synthesize serviceAvailable = _serviceAvailable;
@synthesize lastLocation = _lastLocation;
@synthesize locationDistance = _locationDistance;

+ (CuthbertJuxtapositionMonitor *)sharedMonitor {
    static CuthbertJuxtapositionMonitor *__sharedMonitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedMonitor = [[self alloc] init];
    });
    return __sharedMonitor;
}

- (id)init {
    if (self = [super init]) {
        // put customized initialization logic here, if needed
        self.userAPIToken = @"50295f2e8822700200000002";
        self.timerDuration = 60;
    }
    return self;
}

- (PositionRepo *)positionRepo {
    if (!_positionRepo) {
        _positionRepo = [[PositionRepo alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
    return _positionRepo;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 100;
    }
    return _locationManager;
}

- (void) initTimer {
    UIApplication *application = [UIApplication sharedApplication];
    
    if (application.applicationState == UIApplicationStateBackground) {
        
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
            [application endBackgroundTask:backgroundTask];
        }];
        
        //Background Logic Here
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerDuration target:self selector:@selector(startLocationServices) userInfo:nil repeats:YES];
    
    } else {
        
        [self startLocationServices];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerDuration target:self selector:@selector(startLocationServices) userInfo:nil repeats:YES];
    }
}

- (void) invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void) incrementTimerDuration {
    if (self.timerDuration < 300) {
        self.timerDuration += 60;
        NSLog(@"Set timer duration to %d", self.timerDuration);
        
        [self invalidateTimer];
        [self initTimer];
    } else {
        NSLog(@"Timer is already at max interval.  Keeping existing timer in place.");
    }
}

- (void) resetTimerDuration {
    if (self.timerDuration > 60) {
        self.timerDuration = 60;
        NSLog(@"Reset timer duration to %d seconds.", self.timerDuration);
    
        [self invalidateTimer];
        [self initTimer];
    } else {
        NSLog(@"Timer is already at min interval.  Keeping existing timer in place.");
    }
}

- (void) startLocationServices {
    if (![CLLocationManager locationServicesEnabled]) {
         NSLog(@"LocationService is not enabled.");
    } else {
        if (self.lastLocation == nil || [[[NSDate alloc] init] timeIntervalSinceDate:self.lastLocation.timestamp] > 45) {
            [self.locationManager startUpdatingLocation];
            NSLog(@"LocationServices have been started.");
        } else {
            NSLog(@"LocationServices were throttled.");
        }
    }
}

- (void) stopLocationServices {
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Location monitoring has been stopped.");
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Update failed with error: %@", error);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location Updated!");
    [self stopLocationServices];
    self.lastLocation = newLocation;
    
    if (!oldLocation) {
        //Initial Delegate notification
        if (self.delegate) {
            [self.delegate locationUpdated:newLocation fromLocation:oldLocation];
        }
        
        //Process position
        [self processPosition:newLocation fromLocation:oldLocation];
    } else {
    
        //Delegate notification
        if (self.delegate) {
            [self.delegate locationUpdated:newLocation fromLocation:oldLocation];
        }
        
        //Process position
        [self processPosition:newLocation fromLocation:oldLocation];
        
        //Polling throttle
        self.locationDistance = [newLocation distanceFromLocation:oldLocation];
        
        if (self.locationDistance > 100) {
            [self resetTimerDuration];
        } else {
            [self incrementTimerDuration];
        }
    }
}

- (void) processPosition:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (![self.positionRepo isEmpty]) {
        
        NSLog(@"Positions: %@", [self.positionRepo.positions componentsJoinedByString:@" ||| "]);
        
        if (![self.positionRepo insertPosition:newLocation.coordinate timestamp:newLocation.timestamp]) {
            //Handle local storage error
            NSLog(@"Failed to store position locally.");
        }
        
        [self processLocallyStoredPositions];
        
    } else {
        NSDictionary *position = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithDouble:newLocation.coordinate.latitude], @"position[latitude]",
                                  [NSNumber numberWithDouble:newLocation.coordinate.longitude], @"position[longitude]",
                                  (NSDate *)newLocation.timestamp, @"position[timestamp]", nil];
        NSString *postPathString = [NSString stringWithFormat:@"api/v1/users/%@/positions.json", self.userAPIToken];
        NSLog(@"Post Path String: %@", postPathString);
        
        [[CuthbertJuxtapositionAPIClient sharedClient]
         postPath:postPathString
         parameters:position
         success:^(AFHTTPRequestOperation *operation, id JSON) {
             NSLog(@"Response: %@", JSON);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error posting to Juxtapose!");
             NSLog(@"%@", error);
             NSLog(@"Writing locally...");
             
             //Make call to store locally
             if (![self.positionRepo insertPosition:newLocation.coordinate timestamp:newLocation.timestamp]) {
                 //Handle local storage error; application should probably be restarted.
                 NSLog(@"Failed to store position locally");
             }
         }];
    }

}

- (void) processLocallyStoredPositions {
    self.serviceAvailable = YES;
    
    if (![self.positionRepo isEmpty]) {
        for (Position *pos in self.positionRepo.positions) {
            NSDictionary *position = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (NSNumber *)pos.latitude, @"position[latitude]",
                                      (NSNumber *)pos.longitude, @"position[longitude]",
                                      (NSDate *)pos.timestamp, @"position[timestamp]", nil];
            NSString *postPathString = [NSString stringWithFormat:@"api/v1/users/%@/positions.json", self.userAPIToken];
            
            [[CuthbertJuxtapositionAPIClient sharedClient] postPath:postPathString
                                                         parameters:position
                                                            success:^(AFHTTPRequestOperation *operation, id JSON) {
                                                                NSLog(@"Response: %@", JSON);
                                                                // Delete the locally stored postion
                                                                [self.positionRepo deletePosition:pos];
                                                            }
                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                NSLog(@"Error posting to Juxtapose!");
                                                                NSLog(@"%@", error);
                                                                NSLog(@"Breaking out of ProcessLocallyStoredPositions loop...");
                                                                self.serviceAvailable = NO;
                                                            }];
            if (!self.serviceAvailable) {
                break;
            }
        }
    }
}

@end
