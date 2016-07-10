//
//  PromotionView.m
//  Sueca
//
//  Created by Roger Luan on 7/9/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "PromotionView.h"
#import "Constants.h"

#define SMALL_PADDING 8
#define MEDIUM_PADDING 12
#define LARGE_PADDING 20

@implementation PromotionView

+ (instancetype)viewWithPromotion:(Promotion *)promotion {
	PromotionView *promotionView = [[[NSBundle mainBundle] loadNibNamed:@"PromotionView" owner:self options:nil] firstObject];
	promotionView.promotion = promotion;
//	promotionView.button setTitle
	return promotionView;
}

- (void)setPromotion:(Promotion *)promotion {
	_promotion = promotion;
	self.title.text = promotion.title;
	self.instructions.text = promotion.fullDescription;
	[self.button setTitle:promotion.buttonTitle forState:UIControlStateNormal];
}

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (IBAction)didPressCTAbutton:(UIButton *)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationOpenURL object:self userInfo:@{@"url":self.promotion.buttonURL?self.promotion.buttonURL:[NSNull null]}];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self.title sizeToFit];
	[self.instructions sizeToFit];
	CGFloat height = SMALL_PADDING*2 + self.button.frame.size.height +
					   SMALL_PADDING + self.instructions.frame.size.height +
					   SMALL_PADDING + self.title.frame.size.height +
					 SMALL_PADDING*2;
	
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	CGFloat maxHeight = floor(screenHeight/3);
    if (height > maxHeight) {
        height = maxHeight;
    }
	CGFloat y = screenHeight-49-height+20-[[UIApplication sharedApplication] statusBarFrame].size.height;
	self.frame = CGRectMake(0, y, self.superview.frame.size.width, height);
}

@end
