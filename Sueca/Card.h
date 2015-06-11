//
//  Card.h
//  Sueca
//
//  Created by Roger Oba on 10/15/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Deck;

@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * cardName;
@property (nonatomic, retain) NSString * cardRule;
@property (nonatomic, retain) NSString * cardDescription;
@property (nonatomic, retain) Deck *deck;

@end
