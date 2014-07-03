//
//  Card.h
//  Sueca
//
//  Created by Roger Oba on 6/24/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property(nonatomic,strong) NSString* suit;
@property(nonatomic,strong) NSString* rule;

- (id) initWithRule:(NSString*)newRule suit:(NSString*)newSuit;

@end
