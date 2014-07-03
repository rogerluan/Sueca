//
//  Card.m
//  Sueca
//
//  Created by Roger Oba on 6/24/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id) initWithRule:(NSString*)newRule suit:(NSString*)newSuit {
    self = [super init];
    self.suit = newSuit;
    self.rule = newRule;
    return self;
}

@end
