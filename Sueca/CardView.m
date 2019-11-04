//
//  CardView.m
//  Sueca
//
//  Created by Roger Luan on 4/26/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "CardView.h"
#import "PromotionCardView.h"

@implementation CardView

- (void)setCard:(Card *)card {
	_card = card;
	
	if ([card.cardName isEqualToString:@"promoCard"]) {
		PromotionCardView *promoView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] firstObject];
		promoView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		promoView.heightConstraint.constant = self.frame.size.height;
		promoView.widthConstraint.constant = self.frame.size.width;
		self.progressBar = promoView.progressBar;
		
		if ([GameManager sharedInstance].deck.isDefault) {
			promoView.cardImageFrame.image = [UIImage imageNamed:@"defaultFrame"];
		} else {
			promoView.cardImageFrame.image = [UIImage imageNamed:@"classicFrame"];
		}
		
		promoView.cardImage.image = [UIImage imageNamed:card.cardName];
		promoView.cardLabel.text = card.cardDescription;
		[self addSubview:promoView];
	} else {
		UIImageView *cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		cardImage.contentMode = UIViewContentModeScaleAspectFit;
		cardImage.image = [UIImage imageNamed:card.cardName];
		[self addSubview:cardImage];
	}
}

@end
