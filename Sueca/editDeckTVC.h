//
//  editDeckTVC.h
//  Sueca
//
//  Created by Roger Luan on 10/16/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Card.h"
#import "CustomCardCell.h"

@interface editDeckTVC : UITableViewController

@property (strong,nonatomic) Deck *thisDeck;

@end
