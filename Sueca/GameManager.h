//
//  GameManager.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Deck.h"

@interface GameManager : NSObject

@property (strong, nonatomic) Deck *deck;
@property (strong, nonatomic) NSMutableArray *deckArray;

- (instancetype)init;
- (Card *)newCard;
- (void)refreshDeckArray;

@end
