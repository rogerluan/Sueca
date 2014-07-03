//
//  Deck.m
//  Sueca
//
//  Created by Roger Luan on 10/23/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import "Deck.h"

@implementation Deck

-(id) initWithRule: (NSArray*)assignedRules {
    _cards = [[NSMutableArray alloc] init];
    
    for (int i=0 ; i<assignedRules.count ; i++) {
        for (int numberOfDecks=1 ; numberOfDecks <= (2*4) ; numberOfDecks++) {
            switch (i) {
                case 0: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Um.png"]];
                    break;
                }
                case 1: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Dois.png"]];
                    break;
                }
                case 2: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Tres.png"]];
                    break;
                }
                case 3: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Quatro.png"]];
                    break;
                }
                case 4: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Cinco.png"]];
                    break;
                }
                case 5: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Seis.png"]];
                    break;
                }
                case 6: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Sete.png"]];
                    break;
                }
                case 7: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Oito.png"]];
                    break;
                }
                case 8: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Nove.png"]];
                    break;
                }
                case 9: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Dez.png"]];
                    break;
                }
                case 10: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Valete.png"]];
                    break;
                }
                case 11: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Dama.png"]];
                    break;
                }
                case 12: {
                    [_cards addObject: [[Card alloc] initWithRule: [NSString stringWithFormat: @"%@",[assignedRules objectAtIndex: i]] suit: @"Rei.png"]];
                    break;
                }
            }
        }
    }
    return self;
}

- (Card*) sortCard {
    srand(time(nil));
    int index = rand()%[self.cards count];
    Card* sortedCard = [self.cards objectAtIndex:index];
    [self.cards removeObjectAtIndex: index];
    return sortedCard;
}

@end
