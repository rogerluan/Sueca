//
//  Card.m
//  Sueca
//
//  Created by Roger Oba on 10/15/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "Card.h"
#import "Deck.h"


@implementation Card

@dynamic cardName;
@dynamic cardRule;
@dynamic cardDescription;
@dynamic deck;

- (NSDictionary *)attributes {
	NSMutableDictionary *attributes = [NSMutableDictionary new];
	if (self.cardName) {
		[attributes addEntriesFromDictionary:@{@"CardName":self.cardName}];
	}
	if (self.cardRule) {
		[attributes addEntriesFromDictionary:@{@"CardRule":self.cardRule}];
	}
	if (self.cardDescription) {
		[attributes addEntriesFromDictionary:@{@"CardDesc":self.cardDescription}];
	}
	return [attributes copy];
}

@end
