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
	[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:card.cardName]]];
}

@end
