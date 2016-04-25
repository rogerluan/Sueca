//
//  AnalyticsManager.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "AnalyticsManager.h"
#import "iRate.h"
#import <Parse/Parse.h>

@implementation AnalyticsManager

+ (void)trackGlobalSortCount {
    NSLog(@"Global Sort Count: %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"]);
    NSLog(@"Global Shuffle Count: %ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"globalShuffleCount"]);
    NSDictionary *dimensions = @{@"globalSortCount":[NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"]],
                                 @"globalShuffleCount":[NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"globalShuffleCount"]]};
    
    [PFAnalytics trackEventInBackground:@"globalSortCount"
                             dimensions:dimensions
                                  block:^(BOOL succeeded, NSError *error) {
                                      if (!error) {
                                          NSLog(@"Successfully logged the 'globalSortCount' event");
                                      }
                                  }];
}

+ (void)increaseGlobalSortCount {
    [[iRate sharedInstance] logEvent:NO];
    
    NSInteger globalSortCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"globalSortCount"];
    globalSortCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:globalSortCount forKey:@"globalSortCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (void)increaseGlobalShuffleCount {
    [[iRate sharedInstance] logEvent:NO];
    
    NSInteger globalShuffleCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"globalShuffleCount"];
    globalShuffleCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:globalShuffleCount forKey:@"globalShuffleCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
