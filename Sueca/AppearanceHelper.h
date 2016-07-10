//
//  AppearanceHelper.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TSMessages/TSMessageView.h>

@interface AppearanceHelper : NSObject

+ (void)setup;
+ (void)addShadowToLayer:(CALayer*)layer opacity:(CGFloat)opacity radius:(CGFloat)radius;
+ (CAAnimation *)shakeAnimation;
+ (CAAnimation *)wiggleAnimation;

+ (CAAnimation *)bounceHorizontallyAnimation;
+ (CAAnimation *)bounceVerticallyAnimation;

+ (CAAnimation *)rotationAnimation;

+ (CATransition *)pushFromBottom;

+ (void)defaultBarTintColor;
+ (void)customBarTintColor;
+ (void)customizeMessageView:(TSMessageView *)messageView;

@end
