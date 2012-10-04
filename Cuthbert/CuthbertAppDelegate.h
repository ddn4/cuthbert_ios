//
//  CuthbertAppDelegate.h
//  Cuthbert
//
//  Created by Dan Nemeth on 7/4/12.
//  Copyright (c) 2012 Enterprise Slackers, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuthbertJuxtapositionMonitor.h"

@interface CuthbertAppDelegate : UIResponder <UIApplicationDelegate> {
    UIBackgroundTaskIdentifier backgroundTask;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CuthbertJuxtapositionMonitor *monitor;

// Core Data Hooks
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
