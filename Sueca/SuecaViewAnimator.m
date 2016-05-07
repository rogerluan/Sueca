//
//  SuecaViewAnimator.m
//  Sueca
//
//  Created by Roger Luan on 5/7/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "SuecaViewAnimator.h"

@implementation SuecaViewAnimator

- (void)animateView:(UIView *)view index:(NSUInteger)index views:(NSArray<UIView *> *)views swipeableView:(ZLSwipeableView *)swipeableView {
	CGFloat degree = sin(0.5 * index);
	NSTimeInterval duration = 0.4;
	CGPoint offset = CGPointMake(0, CGRectGetHeight(swipeableView.bounds) * 0.3);
	CGPoint translation = CGPointMake(degree * 10.0, -(index * 3.0));
	[self rotateAndTranslateView:view
					   forDegree:degree
					 translation:translation
						duration:duration
			  atOffsetFromCenter:offset
				   swipeableView:swipeableView];
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
	return degrees * M_PI / 180;
}

- (void)rotateAndTranslateView:(UIView *)view
					 forDegree:(float)degree
				   translation:(CGPoint)translation
					  duration:(NSTimeInterval)duration
			atOffsetFromCenter:(CGPoint)offset
				 swipeableView:(ZLSwipeableView *)swipeableView {
	float rotationRadian = [self degreesToRadians:degree];
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 view.center = [swipeableView convertPoint:swipeableView.center
														  fromView:swipeableView.superview];
						 CGAffineTransform transform =
						 CGAffineTransformMakeTranslation(offset.x, offset.y);
						 transform = CGAffineTransformRotate(transform, rotationRadian);
						 transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y);
						 transform =
						 CGAffineTransformTranslate(transform, translation.x, translation.y);
						 view.transform = transform;
					 }
					 completion:nil];
}

@end
