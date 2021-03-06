//
//  CustomCardCell.h
//  Sueca
//
//  Created by Roger Oba on 10/16/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardRuleCellDelegate <NSObject>

@optional
- (void)cardRuleCell:(UITableViewCell*)cell didPressReturnKeyFromTextField:(UITextField*)cardRuleTextField;
- (void)cardRuleCell:(UITableViewCell*)cell didPressReturnKeyFromTextView:(UITextView*)cardDescriptionTextView;

- (void)cardRuleCell:(UITableViewCell*)cell textFieldDidBeginEditingWithContent:(UITextField *)cardRuleTextField;
- (void)cardRuleCell:(UITableViewCell*)cell textViewDidBeginEditingWithContent:(UITextView *)cardDescriptionTextView;

- (void)cardRuleCell:(UITableViewCell*)cell textFieldDidEndEditingWithContent:(UITextField *)cardRuleTextField;
- (void)cardRuleCell:(UITableViewCell*)cell textViewDidEndEditingWithContent:(UITextView *)cardDescriptionTextView;

@end

@interface CardRulesCell : UITableViewCell <UITextViewDelegate,UITextFieldDelegate>

@property (assign, nonatomic) id<CardRuleCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *cardImageView;
@property (strong, nonatomic) IBOutlet UITextField *cardRuleTextField;
@property (strong, nonatomic) IBOutlet UITextView *cardDescriptionTextView;

@end
