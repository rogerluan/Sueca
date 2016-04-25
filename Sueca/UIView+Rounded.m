//
//  UIView+Rounded.m
//  Patient
//
//  Created by Caio Cezar Lopes dos Santos on 10/18/15.
//  Copyright © 2015 GoDoctor. All rights reserved.
//

#import "UIView+Rounded.h"

@implementation UIView (Rounded)

@dynamic cornerRadius;
@dynamic borderWidth;
@dynamic borderColor;

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

@end
