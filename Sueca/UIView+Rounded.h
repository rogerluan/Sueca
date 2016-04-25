//
//  UIView+Rounded.h
//  Patient
//
//  Created by Caio Cezar Lopes dos Santos on 10/18/15.
//  Copyright © 2015 GoDoctor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Rounded)

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, weak) IBInspectable UIColor *borderColor;

@end