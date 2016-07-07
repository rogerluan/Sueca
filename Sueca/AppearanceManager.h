//
//  AppearanceManager.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppearanceManager : NSObject

+ (void)setup;
+ (void)addShadowToLayer:(CALayer*)layer opacity:(CGFloat)opacity radius:(CGFloat)radius;

+ (void)defaultBarTintColor;
+ (void)customBarTintColor;

@end
