//
//  a20AppDelegate.h
//  Sueca
//
//  Created by Roger Luan on 10/23/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface a20AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
