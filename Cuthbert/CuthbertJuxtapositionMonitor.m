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
@synthesize userAPIToken = _userAPIToken;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize positionRepo = _positionRepo;
@synthesize serviceAvailable = _serviceAvailable;

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
        NSLog(@"JuxMonitor::Background logic commencing...");
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(startLocationServices) userInfo:nil repeats:YES];
                       
//        if (backgroundTask != UIBackgroundTaskInvalid) {
//            [application endBackgroundTask:backgroundTask];
//            backgroundTask = UIBackgroundTaskInvalid;
//        }
        
    } else {
        [self startLocationServices];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(startLocationServices) userInfo:nil repeats:YES];
    }

}

- (void) startLocationServices {    
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];       
        NSLog(@"LocationService has been enabled.");
    } else {
        NSLog(@"LocationService is not enabled.");
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
    if (self.delegate) {
        [self.delegate locationUpdated:newLocation fromLocation:oldLocation];
    }
    
    NSLog(@"Location Updated!");
    [self stopLocationServices];
    
    if (![self.positionRepo isEmpty]) {
        
        NSLog(@"Positions: %@", [self.positionRepo.positions componentsJoinedByString:@" ||| "]);
        
        if (![self.positionRepo insertPosition:newLocation.coordinate timestamp:newLocation.timestamp]) {
            //Handle local storage error
            NSLog(@"Failed to store position locally.");
        }
        
        // NEED TO ADD LOGIC TO ATTEMPT TO POST POSITIONS!!!
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
