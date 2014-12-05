//
//  RegrasViewController.h
//  Sueca
//
//  Created by Roger Luan on 11/1/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface RegrasViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *rules;
@property (strong, nonatomic) NSArray *imagemcards;

@end