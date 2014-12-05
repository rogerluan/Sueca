//
//  Deck.h
//  Sueca
//
//  Created by Roger Luan on 12/5/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Deck : NSManagedObject

@property (nonatomic, retain) NSString * deckName;
@property (nonatomic, retain) NSNumber * isBeingUsed;
@property (nonatomic, retain) NSNumber * isEditable;
@property (nonatomic, retain) NSSet *cards;
@end

@interface Deck (CoreDataGeneratedAccessors)

- (void)addCardsObject:(Card *)value;
- (void)removeCardsObject:(Card *)value;
- (void)addCards:(NSSet *)values;
- (void)removeCards:(NSSet *)values;

@end
