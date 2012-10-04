//
//  PositionRepo.m
//  Cuthbert
//
//  Created by Dan Nemeth on 8/9/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import "PositionRepo.h"

@implementation PositionRepo

@synthesize positions = _positions;
@synthesize context = _context;

- (PositionRepo *) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if (self) {
        self.context = managedObjectContext;
    }
    return self;
}

// Override positions setter method to retrieve postions from managedContext in chrono order
- (NSMutableArray *) positions {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:self.context];
    [request setEntity:entity];
        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
        
    NSError *error = nil;
    NSMutableArray *results = [[self.context executeFetchRequest:request error:&error] mutableCopy];
        
    if (results == nil) {
        // Handle the error.  Application SHOULD FAIL and be RESTARTED?
        _positions = [[NSMutableArray alloc] init];
    } else {
        _positions = results;
    }
    
    return _positions;
}

- (BOOL) isEmpty {
    if (self.positions.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) insertPosition:(CLLocationCoordinate2D)coordinate timestamp:(NSDate *)time {
    Position *pos = (Position *)[NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.context];
    
    pos.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    pos.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    pos.timestamp = time;
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        // Handle the error.
        NSLog(@"Error saving local position.");
        return NO;
    }
    NSLog(@"Position %@, %@, saved.", pos.latitude, pos.longitude);
    return YES;
}

- (BOOL) deletePosition:(Position *)positionToDelete {
    [self.context deleteObject:positionToDelete];
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        // Handle the error.
        NSLog(@"Error deleting local position.");
        return NO;
    }
    NSLog(@"Position deleted.");
    return YES;
}

@end
