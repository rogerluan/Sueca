//
//  CustomCardCell.h
//  Sueca
//
//  Created by Roger Luan on 10/16/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardRulesCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cardImageView;
@property (strong, nonatomic) IBOutlet UITextField *cardRuleTextField;
@property (strong, nonatomic) IBOutlet UITextView *cardDescriptionTextView;

@end
