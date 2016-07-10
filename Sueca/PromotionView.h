//
//  PromotionView.h
//  Sueca
//
//  Created by Roger Luan on 7/9/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promotion.h"

@interface PromotionView : UIView

@property (strong, nonatomic) Promotion *promotion;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *title; //supports max 50 characters on 3.5" and 4" iPhones, 60 on 4.7", and 68 on 5.5"
@property (strong, nonatomic) IBOutlet UILabel *instructions; //supports max 72 characters on 3.5" iPhones (2 lines), 140 on 4" iPhones (4 lines), 168 on 4.7" (4 lines), and 180 on 5.5" (4 lines)
@property (strong, nonatomic) IBOutlet UIButton *button;

+ (instancetype)viewWithPromotion:(Promotion *)promotion;

@end