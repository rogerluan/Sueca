//
//  EditDeckTableViewController.h
//  Sueca
//
//  Created by Roger Oba on 10/16/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Card.h"
#import "CardRulesCell.h"

@interface EditDeckTableViewController : UITableViewController

@property (strong,nonatomic) Deck *thisDeck;
@property (strong,nonatomic) NSString *deckLabel;

@end
