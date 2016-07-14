//
//  ShareViewController.h
//  Sueca
//
//  Created by Roger Luan on 7/7/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface ShareViewController : UIActivityViewController

+ (instancetype)initWithCard:(Card *)card;

@end
