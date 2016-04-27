//
//  SuecaSwipeDeterminator.m
//  Sueca
//
//  Created by Roger Luan on 4/26/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "SuecaSwipeDeterminator.h"
#import "Utils.h"

@implementation SuecaSwipeDeterminator

- (BOOL)shouldSwipeView:(UIView *)view
			   movement:(ZLSwipeableViewMovement *)movement
		  swipeableView:(ZLSwipeableView *)swipeableView {
	if ([view isEqual:swipeableView.topView]) {
		CGPoint translation = movement.translation;
		CGPoint velocity = movement.velocity;
		CGRect bounds = swipeableView.bounds;
		CGFloat minTranslationInPercent = swipeableView.minTranslationInPercent;
		CGFloat minVelocityInPointPerSecond = swipeableView.minVelocityInPointPerSecond;
		CGFloat allowedDirection = swipeableView.allowedDirection;
		
		return [self isDirectionAllowed:translation allowedDirection:allowedDirection] &&
		[self isTranslation:translation inTheSameDirectionWithVelocity:velocity] &&
		([self isTranslationLargeEnough:translation
				minTranslationInPercent:minTranslationInPercent
								 bounds:bounds] ||
		 [self isVelocityLargeEnough:velocity
		 minVelocityInPointPerSecond:minVelocityInPointPerSecond]);
	}
	return NO;
}

- (BOOL)isTranslation:(CGPoint)p1 inTheSameDirectionWithVelocity:(CGPoint)p2 {
	return [self signNum:p1.x] == [self signNum:p2.x] && [self signNum:p1.y] == [self signNum:p2.y];
}

- (BOOL)isDirectionAllowed:(CGPoint)translation
		  allowedDirection:(ZLSwipeableViewDirection)allowedDirection {
	return (ZLSwipeableViewDirectionFromPoint(translation) & allowedDirection) !=
	ZLSwipeableViewDirectionNone;
}

- (BOOL)isTranslationLargeEnough:(CGPoint)translation
		 minTranslationInPercent:(CGFloat)minTranslationInPercent
						  bounds:(CGRect)bounds {
	return ABS(translation.x) > minTranslationInPercent * bounds.size.width ||
	ABS(translation.y) > minTranslationInPercent * bounds.size.height;
}

- (BOOL)isVelocityLargeEnough:(CGPoint)velocity
  minVelocityInPointPerSecond:(CGFloat)minVelocityInPointPerSecond {
	return CGPointMagnitude(velocity) > minVelocityInPointPerSecond;
}

- (NSInteger)signNum:(CGFloat)n {
	return (n < 0) ? -1 : (n > 0) ? +1 : 0;
}

@end
