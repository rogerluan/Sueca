//
//  CardDescriptionView.h
//  Project Epsilon
//
//  Created by Roger Luan on 9/12/14.
//  Copyright (c) 2014 Cupula Mobile. All rights reserved.
//

#import "CustomIOS7AlertView.h"

@interface CardDescriptionView : CustomIOS7AlertView

@property (strong,nonatomic) UILabel *cardHeader;
@property (strong,nonatomic) UIImageView *cardImage;
@property (strong,nonatomic) UILabel *cardTitle;
@property (strong,nonatomic) UILabel *cardDescription;
@property (strong,nonatomic) UIScrollView *scrollView;

- (id)init;
- (void) showAlertWithHeader:(NSString*) header image:(UIImage*)image title:(NSString*)title description:(NSString*)description sender:(id)sender;
- (void) closeAlert:(id)sender;

@end
