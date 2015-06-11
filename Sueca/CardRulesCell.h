//
//  CustomCardCell.h
//  Sueca
//
//  Created by Roger Oba on 10/16/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardRulesCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *cardImageView;
@property (strong, nonatomic) IBOutlet UITextField *cardRuleTextField;
@property (strong, nonatomic) IBOutlet UITextView *cardDescriptionTextView;

@end
