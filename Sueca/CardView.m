//
//  CardView.m
//  Sueca
//
//  Created by Roger Luan on 4/26/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (void)setCard:(Card *)card {
	_card = card;
	UIImageView *cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	cardImage.image = [UIImage imageNamed:card.cardName];
	[self addSubview:cardImage];
}

@end
