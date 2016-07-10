//
//  AppearanceHelper.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "AppearanceHelper.h"
#import "TSBlurView.h"

#define kWiggleBounceY 1.0f
#define kWiggleBounceX 1.5f
#define kWiggleBounceDuration 0.3
#define kWiggleBounceDurationVariance 0.025

#define kWiggleRotateAngle 0.01f
#define kWiggleRotateDuration 0.3
#define kWiggleRotateDurationVariance 0.025

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

#pragma mark - Bar Tint Color

+ (void)defaultBarTintColor {
	[[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
}

+ (void)customBarTintColor {
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.039 green:0.128 blue:0.048 alpha:1.000]];
	
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

+ (CAAnimation *)wiggleAnimation {
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	
	CGFloat wobbleAngle = 0.06f;
	NSValue *valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
	NSValue *valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];

	animation.values = @[valLeft, valRight];
	animation.duration = 0.1;
	animation.autoreverses = YES;
	animation.repeatCount = HUGE_VALF;
	return animation;
}

+ (CAAnimation *)rotationAnimation {
	CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.values = @[@(-kWiggleRotateAngle), @(kWiggleRotateAngle)];
	
	animation.autoreverses = YES;
	animation.duration = [self randomizeInterval:kWiggleRotateDuration
									withVariance:kWiggleRotateDurationVariance];
	animation.repeatCount = HUGE_VALF;
	
	return animation;
}

+ (CAAnimation *)bounceVerticallyAnimation {
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
	animation.values = @[@(kWiggleBounceY), @(0.0)];
	
	animation.autoreverses = YES;
	animation.duration = [self randomizeInterval:kWiggleBounceDuration
									withVariance:kWiggleBounceDurationVariance];
	animation.repeatCount = HUGE_VALF;
	
	return animation;
}

+ (CAAnimation *)bounceHorizontallyAnimation {
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
	animation.values = @[@(kWiggleBounceX), @(0.0)];
	
	animation.autoreverses = YES;
	animation.duration = [self randomizeInterval:kWiggleBounceDuration
									withVariance:kWiggleBounceDurationVariance];
	animation.repeatCount = HUGE_VALF;
	
	return animation;
}

+ (NSTimeInterval)randomizeInterval:(NSTimeInterval)interval withVariance:(double)variance {
	double random = (arc4random_uniform(1000) - 500.0) / 500.0;
	return interval + variance * random;
}

+ (CATransition *)pushFromBottom {
	CATransition *transition = [CATransition animation];
	transition.duration = 0.5;
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromTop;
	return transition;
}

#pragma mark - TSMessage

+ (void)customizeMessageView:(TSMessageView *)messageView {
	if (![messageView.title isEqualToString:NSLocalizedString(@"Deck Shuffled", @"Deck shuffled warning title")] &&
		![messageView.title isEqualToString:NSLocalizedString(@"Update Available", @"Update available warning title")]) {
		
		for (UIView *view in messageView.subviews) {
			if ([view isKindOfClass:[TSBlurView class]]) {
				if (NSClassFromString(@"UIVisualEffectView") != nil) {
					//UIViewVisualEffectView is available, so add it.
					
					UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
					UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:view.frame];
					effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
					effectView.effect = blurEffect;
					[messageView insertSubview:effectView aboveSubview:view];
					[view removeFromSuperview];
				} else { //UIViewVisualEffectView is available, so don't do anything.
					view.alpha = 0.85;
				}
			}
		}
	}
}

@end