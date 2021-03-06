//
//  Deck.h
//  Sueca
//
//  Created by Roger Oba on 12/5/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Deck : NSManagedObject

@property (nonatomic, retain) NSString *deckName;
@property (nonatomic, retain) NSNumber *isBeingUsed;
@property (nonatomic, retain) NSNumber *isEditable;
@property (nonatomic, retain) NSSet *cards;
@property (assign, readonly, getter=isDefault) BOOL defaultDeck;
@property (assign, readonly, getter=attributes) NSDictionary *attributes;

@end

@interface Deck (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;
- (BOOL)isDefault;
- (NSDictionary *)attributes;

+ (Deck *)newDeckWithLabel:(NSString *)deckLabel;
+ (void)createDefaultDeck;
+ (Deck *)defaultDeckExist;

@end