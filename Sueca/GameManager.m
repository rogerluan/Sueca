//
//  GameManager.m
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "GameManager.h"
#import "Deck.h"
#import "Constants.h"

@interface GameManager ()

@property (strong, nonatomic) NSManagedObjectContext *moc;

@end

@implementation GameManager

#pragma mark - Public Methods -

- (instancetype)init {
    if(!(self = [super init])) return nil;
	
	self.deck = [self deck];
	[self refreshDeckArray];
    return self;
}

- (Card *)newCard {
    if ([self isCardAvailable]) {
        Card *displayCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
        
        /* Randomly picks a card from the deck */
        NSUInteger randomIndex = arc4random() % [self.deckArray count];
        displayCard = [self.deckArray objectAtIndex:randomIndex];
        [self.deckArray removeObjectAtIndex:randomIndex];
        return displayCard;
    } else {
        [self refreshDeckArray];
        return [self newCard];
    }
}

/**
 *  Getter method for the current deck.
 *  @return Deck containing the cards that should be used, or nil if any error occurs.
 */
- (Deck *)deck {
    self.moc = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck" inManagedObjectContext:self.moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isBeingUsed == %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *deckBeingUsedFetchedObjects = [self.moc executeFetchRequest:fetchRequest error:&error];
	Deck *deckBeingUsed = [deckBeingUsedFetchedObjects firstObject];
    if (deckBeingUsed == nil || ([deckBeingUsedFetchedObjects count] == 0)) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        @try {
            Deck *defaultDeck = [Deck defaultDeckExist];
            if (defaultDeck) {
                defaultDeck.isBeingUsed = [NSNumber numberWithBool:YES];
                
                NSError *coreDataError = nil;
                if(![self.moc save: &coreDataError]) {
                    NSLog(@"Unresolved error %@, %@", coreDataError, [coreDataError userInfo]);
                } else {
                    NSLog(@"Successfully solved a potential crash! Identifier: There was no deck being used, so it selected default deck to be used.");
                }
            } else {
                @throw [NSException exceptionWithName:@"noDefaultDeck" reason:@"For some reason, the default deck wasn't instantiated." userInfo:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception %@ caught. Exception reason: %@. Trying to solve it now.", exception.name, exception.reason);
            if (![Deck defaultDeckExist]) {
                [Deck createDefaultDeck];
            } else {
                NSLog(@"Everything was tried. No solution found. Aborting.");
                abort();
            }
        }
        @finally {
            NSLog(@"Successfully solved a potential crash! Hell yeah!");
            return self.deck;
        }
    } else {
        return [deckBeingUsedFetchedObjects firstObject];
    }
}

#pragma mark - Private Methods -

- (BOOL)isCardAvailable {
    /* If there're no more cards in the deck, it reshuffles and warns the user */
    NSLog(@"card count: %ld",(long)self.deckArray.count);
    if (self.deckArray.count == 0) {
        /* Warns the user that the deck was reshuffled */
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == ShuffleDeckWarningDisplay) {
            NSInteger warningCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"noShuffleDeckWarningCount"];
            warningCount++;
            [[NSUserDefaults standardUserDefaults] setInteger:warningCount forKey:@"noShuffleDeckWarningCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deckShuffled" object:nil userInfo:@{@"noShuffleDeckWarningCount":[NSNumber numberWithInteger:warningCount]}];
        } else {
            NSLog(@"showShuffledDeckWarning = %ld\nIf it's 0, bug. Else if it's 2, user opted out.",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"]);
        }
        return NO;
    }
    return YES;
}

/**
 *  Creates a full deck with 52 cards
 *  @return NSMutableArray containing the full deck
 */
- (NSMutableArray *)fullDeck {
    NSMutableArray *fullDeck = [NSMutableArray new];
    
    /* If it's the default deck, simply create 13 * 4 = 52 cards */
    if (self.deck.isDefault) {
        for (Card *card in self.deck.cards) {
            for (int i = 0; i < 4; i++) {
                [fullDeck addObject:card];
            }
        }
    } else { /* Else if it's a custom deck, create cards accordingly with the suit */
        for (Card *card in self.deck.cards) {
            Card *c_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
            c_tempCard.cardRule = card.cardRule;
            c_tempCard.cardDescription = card.cardDescription;
            c_tempCard.cardName = [NSString stringWithFormat:@"%@C",[card.cardName substringToIndex:3]];
            [fullDeck addObject:c_tempCard];
            
            Card *d_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
            d_tempCard.cardRule = card.cardRule;
            d_tempCard.cardDescription = card.cardDescription;
            d_tempCard.cardName = [NSString stringWithFormat:@"%@D",[card.cardName substringToIndex:3]];
            [fullDeck addObject:d_tempCard];
            
            Card *h_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
            h_tempCard.cardRule = card.cardRule;
            h_tempCard.cardDescription = card.cardDescription;
            h_tempCard.cardName = [NSString stringWithFormat:@"%@H",[card.cardName substringToIndex:3]];
            [fullDeck addObject:h_tempCard];
            
            Card *s_tempCard = [NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:self.moc];
            s_tempCard.cardRule = card.cardRule;
            s_tempCard.cardDescription = card.cardDescription;
            s_tempCard.cardName = [NSString stringWithFormat:@"%@S",[card.cardName substringToIndex:3]];
            [fullDeck addObject:s_tempCard];
        }
    }
    return fullDeck;
}

#pragma mark - Helpers -

- (void)refreshDeckArray {
    if (self.deck) {
        [self.deckArray removeAllObjects];
        self.deckArray = [self fullDeck];
    } else {
		self.deck = [self deck];
		//here we should call refreshDeckArray again, but could enter cycle.
    }
}

#pragma mark - Core Data -

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
