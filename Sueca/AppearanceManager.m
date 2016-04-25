//
//  AppearanceManager.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "AppearanceManager.h"

@implementation AppearanceManager

+ (void)setup {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.039 green:0.128 blue:0.048 alpha:1.000]];
    [[UITabBar appearance] setBackgroundColor:[UIColor greenColor]];
}

#pragma mark - Shadowing Method

/**
 *  Adds a shadow to the given layer.
 *
 *  Shadow is black, with 90% of opacity and radius of 10.0f.
 *
 *  @param layer that will have the shadow added on.
 *  @author Roger Oba
 *
 */
+ (void)addShadowToLayer:(CALayer*)layer opacity:(CGFloat)opacity radius:(CGFloat)radius {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = opacity;
    layer.shadowRadius = radius;
    layer.shadowOffset = CGSizeZero;
    layer.masksToBounds = NO;
}

@end
