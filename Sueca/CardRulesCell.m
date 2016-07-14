//
//  CustomCardCell.m
//  Sueca
//
//  Created by Roger Oba on 10/16/14.
//  Copyright (c) 2014 Roger Oba. All rights reserved.
//

#import "CardRulesCell.h"
#import "AppearanceHelper.h"

@implementation CardRulesCell

@synthesize delegate;

- (void)awakeFromNib {
	[super awakeFromNib];
    [AppearanceHelper addShadowToLayer:self.cardImageView.layer opacity:0.5 radius:3.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(cardRuleCell:textFieldDidBeginEditingWithContent:)]) {
		[self.delegate cardRuleCell:self textFieldDidBeginEditingWithContent:textField];
	}
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(cardRuleCell:didPressReturnKeyFromTextField:)]) {
		[self.delegate cardRuleCell:self didPressReturnKeyFromTextField:textField];
	}
    return YES;
}

- (void)textFieldDidEndEditing:(nonnull UITextField *)cardRuleTextField {
    if ([cardRuleTextField.text isEqualToString:@""] || cardRuleTextField.text == nil) {
        cardRuleTextField.placeholder = NSLocalizedString(@"Tap to add a rule", nil);
        cardRuleTextField.textColor = [UIColor grayColor];
    } else {
        NSLog(@"Text field has content: %@",cardRuleTextField.text);
        cardRuleTextField.textColor = [UIColor whiteColor];
		if ([self.delegate respondsToSelector:@selector(cardRuleCell:textFieldDidEndEditingWithContent:)]) {
			[self.delegate cardRuleCell:self textFieldDidEndEditingWithContent:cardRuleTextField];
		}
    }
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(cardRuleCell:textViewDidBeginEditingWithContent:)]) {
		[self.delegate cardRuleCell:self textViewDidBeginEditingWithContent:textView];
	}
    if ([textView.text isEqualToString:NSLocalizedString(@"Tap to add a description", nil)]) {
        [textView setText: nil];
    }
    [textView setTextColor:[UIColor whiteColor]];
}

- (void)textViewDidEndEditing:(UITextView *)cardDescriptionTextView {
    
    NSString *trimmedTextViewContent = [cardDescriptionTextView.text stringByTrimmingCharactersInSet:
    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedTextViewContent isEqualToString:@""] || trimmedTextViewContent == nil) {
        cardDescriptionTextView.textColor = [UIColor lightGrayColor];
        cardDescriptionTextView.text = NSLocalizedString(@"Tap to add a description", nil);
    } else {
        NSLog(@"Text view has content: %@",trimmedTextViewContent);
        cardDescriptionTextView.text = trimmedTextViewContent;
		if ([self.delegate respondsToSelector:@selector(cardRuleCell:textViewDidEndEditingWithContent:)]) {
			[self.delegate cardRuleCell:self textViewDidEndEditingWithContent:cardDescriptionTextView];
		}
    }
}

- (BOOL)textView:(nonnull UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
		if ([self.delegate respondsToSelector:@selector(cardRuleCell:didPressReturnKeyFromTextView:)]) {
			[self.delegate cardRuleCell:self didPressReturnKeyFromTextView:textView];
		}
        return NO;
    } else {
        return YES;
    }
}

@end
