//
//  JogoViewController.h
//  Sueca
//
//  Created by Bruno Pedroso on 25/10/13.
//  Copyright (c) 2013 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "RegrasViewController.h"

@interface JogoViewController : UIViewController

@property (strong,nonatomic) Deck *deck;
@property (strong,nonatomic) Card *cardDaVez;

@property (strong,nonatomic) NSArray *rulesPadrao;



@end
