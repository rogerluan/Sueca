//
//  AppearanceHelper.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "AppearanceHelper.h"

@implementation AppearanceHelper

+ (void)setup {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
	[[UITabBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.039 green:0.128 blue:0.048 alpha:1.000]];
	[[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.035 green:0.224 blue:0.129 alpha:1.000]];
	[[UITabBar appearance] setTintColor:[UIColor whiteColor]];
	
}

#pragma mark - Shadowing Method

/**
 *  Adds a shadow to the given layer.
 *  Shadow is black, with 90% of opacity and radius of 10.0f.
 *
 *  @param layer that will have the shadow added on.
 *
 */
+ (void)addShadowToLayer:(CALayer*)layer opacity:(CGFloat)opacity radius:(CGFloat)radius {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = opacity;
    layer.shadowRadius = radius;
    layer.shadowOffset = CGSizeZero;
    layer.masksToBounds = NO;
}

#pragma mark - Animations

+ (CAAnimation *)shakeAnimation {
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	
	CGFloat wobbleAngle = 0.06f;
	
	NSValue *valLeft;
	NSValue *valRight;
	NSMutableArray *values = [NSMutableArray new];
	
	for (int i = 0; i < 5; i++) {
		valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
		valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
		[values addObjectsFromArray:@[valLeft, valRight]];
		wobbleAngle*=0.66;
	}
	animation.values = [values copy];
	animation.duration = 0.7;
	return animation;
}

@end
