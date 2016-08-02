//
//  PromotionView.m
//  Sueca
//
//  Created by Roger Luan on 7/9/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "PromotionView.h"

#define SMALL_PADDING 8
#define MEDIUM_PADDING 12
#define LARGE_PADDING 20

static NSString * const kFacebookURL = @"https://www.facebook.com/suecadrinkinggame/";

@implementation PromotionView

+ (instancetype)viewWithPromotion:(Promotion *)promotion {
	PromotionView *promotionView = [[[NSBundle mainBundle] loadNibNamed:@"PromotionView" owner:self options:nil] firstObject];
	promotionView.promotion = promotion;
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
	self.title.text = NSLocalizedString(@"Do you like drinking with friends?", nil);
	self.instructions.text = NSLocalizedString(@"Don't answer! It doesn't matter - we know you are a Sueca fan. Like our page on facebook to show your love!", nil);
	[self.button setTitle:NSLocalizedString(@"Sueca Facebook Fanpage", nil) forState:UIControlStateNormal];
	[self layoutSubviews];
}

- (IBAction)didPressCTAbutton:(UIButton *)sender {
	NSURL *url = self.promotion.buttonURL?self.promotion.buttonURL:[NSURL URLWithString:kFacebookURL];
	[[NSNotificationCenter defaultCenter] postNotificationName:SuecaNotificationOpenURL object:self userInfo:@{@"url":url}];
	[AnalyticsManager logEvent:AnalyticsEventCTAButton withAttributes:@{@"url":url, @"buttonTitle":self.button.titleLabel}];
}

- (void)layoutSubviews {
	[super layoutSubviews];
//	[self.title sizeToFit];
//	[self.instructions sizeToFit];
//	[self.button sizeToFit];

	CGFloat height = SMALL_PADDING*2 + self.button.frame.size.height +
					   SMALL_PADDING + self.instructions.frame.size.height +
					   SMALL_PADDING + self.title.frame.size.height +
					 SMALL_PADDING*2;
//	NSLog(@"button frame: %@, instructions frame: %@, title frame: %@", NSStringFromCGRect(self.button.frame), NSStringFromCGRect(self.instructions.frame), NSStringFromCGRect(self.title.frame));
	
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat maxHeight = floor(screenHeight/3);
    if (height > maxHeight) {
        height = maxHeight;
    }
	CGFloat y = screenHeight-49-height+20-[[UIApplication sharedApplication] statusBarFrame].size.height;
	self.frame = CGRectMake(0, y, screenWidth, height);
	NSLog(@"self.frame: %@", NSStringFromCGRect(self.frame));
}

@end
