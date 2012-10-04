//
//  PositionRepo.h
//  Cuthbert
//
//  Created by Dan Nemeth on 8/9/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"


@interface PositionRepo : NSObject

@property (nonatomic, strong) NSMutableArray *positions;
@property (nonatomic, strong) NSManagedObjectContext *context;

- (PositionRepo *) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (BOOL) isEmpty;
- (BOOL) insertPosition: (CLLocationCoordinate2D)coordinate timestamp:(NSDate *)time;
- (BOOL) deletePosition: (Position *)positionToDelete;

@end
