
//
//  FabricSetup.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "FabricSetup.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation FabricSetup

+ (void)setupWithLaunchOptions:(NSDictionary *)launchOptions {
    //Fabric Crashalytics
    [Fabric with:@[CrashlyticsKit]];
    
    //Parse Analytics
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"tfea6juIRlSfNmdNDczjhvJ8HkDLBGudLnfBWnBr"
                  clientKey:@"SmnuevW7amI36UrOHxOWzdY2zeVo74qO7YgI8S1m"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}


@end
