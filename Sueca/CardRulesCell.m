//
//  CustomCardCell.m
//  Sueca
//
//  Created by Roger Luan on 10/16/14.
//  Copyright (c) 2014 Roger Luan. All rights reserved.
//

#import "CardRulesCell.h"

@implementation CardRulesCell

- (void)awakeFromNib {
    // Initialization code
	self.cardRuleTextField.textColor = [UIColor whiteColor];
	self.cardDescriptionTextView.textColor = [UIColor whiteColor];
	self.cardDescriptionTextView.backgroundColor = [UIColor clearColor];
	self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
