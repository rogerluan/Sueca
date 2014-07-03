//
//  Deck.h
//  Sueca
//
//  Created by Roger Luan on 10/23/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

@property (nonatomic,strong) NSMutableArray* cards;

- (id) initWithRule: (NSArray*)rules;
- (Card*) sortCard;

@end