//
//  PromotionCardView.h
//  Sueca
//
//  Created by Roger Luan on 7/6/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionCardView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *cardImageFrame;
@property (strong, nonatomic) IBOutlet UIImageView *cardImage;
@property (strong, nonatomic) IBOutlet UILabel *cardLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@end
