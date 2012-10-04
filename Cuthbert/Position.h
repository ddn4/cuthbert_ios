//
//  Position.h
//  Cuthbert
//
//  Created by Dan Nemeth on 8/9/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Position : NSManagedObject

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSDate * timestamp;

@end
