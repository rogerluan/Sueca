//
//  a20AppDelegate.m
//  Sueca
//
//  Created by Roger Oba on 10/23/13.
//  Copyright (c) 2013 Roger Oba. All rights reserved.
//

#import "a20AppDelegate.h"
#import "iRateCoordinator.h"
#import "AnalyticsManager.h"
#import "AppearanceManager.h"
#import "NotificationManager.h"
#import "Constants.h"
#import "CloudKitManager.h"

#import <TSMessages/TSMessageView.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <CloudKit/CloudKit.h>

@implementation a20AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (void)initialize {
    [iRateCoordinator setup];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AppearanceManager setup];
    [iRateCoordinator resetEventCount];
	[Fabric with:@[CrashlyticsKit]];
    [TSMessageView addNotificationDesignFromFile:@"SuecaNotificationDesign.json"];
#warning to-do: remove this from App Delegate and implement the custom notification card.
	[NotificationManager registerForRemoteNotifications];
	[CloudKitManager clearBadges];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [AnalyticsManager trackGlobalSortCount];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
 
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Sueca Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
 
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sueca.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    //    Code to support lightweight core data migration
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES };
    
    
    //and add the options I've just created above, in the options parametere below:
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
 
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Remote Notifications 

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
	NSString *alertBody = cloudKitNotification.alertBody;
	NSLog(@"Received Push Notification! Alert body: %@", alertBody);
	if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
		[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationDidReceiveRemoteNotification object:nil userInfo:[(CKQueryNotification *)cloudKitNotification recordFields]];
	}
}*/

/*
 *  Used when receiving silent push notifications from background mode
 *
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
	UIBackgroundTaskIdentifier taskIdentifier = [application beginBackgroundTaskWithName:@"Task" expirationHandler:^{
		NSLog(@"Task exceeded time limit.");
	}];
	NSLog(@"Notification with user info: %@", userInfo);
	if (userInfo[@"aps"][@"content-available"] || userInfo[@"aps"][@"alert"]) {
		if (application.applicationState == UIApplicationStateBackground) {
			NSLog(@"Inactive or Background");
			
			CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
			CKRecordID *promotionID = [(CKQueryNotification *)cloudKitNotification recordID];
			
			if (userInfo[@"aps"][@"content-available"]) {
				NSLog(@"Content available = YES");
				
				[[[CKContainer defaultContainer] publicCloudDatabase] fetchRecordWithID:promotionID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
					NSLog(@"record: %@, error: %@", record, error);
					
					UILocalNotification *notification = [UILocalNotification new];
					notification.alertBody = record[@"push_message"];
					notification.soundName = record[@"push_soundName"];
					if ([record[@"push_shouldIncrementBadge"] intValue] == 1) {
						NSInteger iconBadgeNumber = [application applicationIconBadgeNumber];
						notification.applicationIconBadgeNumber = ++iconBadgeNumber;
					}
					notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:[record[@"push_fireDelayInSeconds"] doubleValue]];
					notification.userInfo = @{@"recordName":promotionID.recordName};
					
					[[UIApplication sharedApplication] scheduleLocalNotification:notification];
					
					[application endBackgroundTask:taskIdentifier];
					completionHandler(UIBackgroundFetchResultNewData);
				}];
			} else {
				NSLog(@"Content available = NO");
				
				[[[CKContainer defaultContainer] publicCloudDatabase] fetchRecordWithID:promotionID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
					NSLog(@"record: %@, error: %@", record, error);
					
					[application endBackgroundTask:taskIdentifier];
					completionHandler(UIBackgroundFetchResultNewData);
				}];
			}
		} else {
			NSLog(@"Active");
			[CloudKitManager clearBadges];
			
			//To-do: Show an in-app banner
			
			completionHandler(UIBackgroundFetchResultNewData);
		}
	} else {
		NSLog(@"Not relevant push notification");
		completionHandler(UIBackgroundFetchResultNewData);
	}
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
		NSLog(@"Opened local notification from background");
		NSString *recordName = [notification.userInfo objectForKey:@"recordName"];
		NSLog(@"RecordName: %@", recordName);
	} else {
		NSLog(@"Opened local notification in foreground");
		//To-do: show an in-app banner
	}
	[CloudKitManager clearBadges];
}

@end
