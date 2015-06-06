//
//  AchievementAlertView.m
//  Project Epsilon
//
//  Created by Roger Luan on 9/12/14.
//  Copyright (c) 2014 Cupula Mobile. All rights reserved.
//

#import "CardDescriptionView.h"

#define ALERT_WIDTH 290.0
#define HEADER_HEIGHT 44.0
#define BUTTON_HEIGHT 50
#define DEFAULT_SPACING 20.0

@implementation CardDescriptionView

- (id)init {
    self = [super init];
    if (self) {
        
        //CONTAINER
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, ALERT_WIDTH, 400)];
        
        
        
        //HEADER
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, ALERT_WIDTH, HEADER_HEIGHT)];
		header.backgroundColor = [UIColor colorWithRed:0.207 green:0.646 blue:0.411 alpha:1.000];
        
        
        
        //CARD IMAGE
        CGSize imageViewSize = CGSizeMake(140.0, 140.0);
        self.cardImage = [[UIImageView alloc] initWithFrame:CGRectMake(ALERT_WIDTH/2-imageViewSize.width/2, header.frame.size.height+30.0, imageViewSize.width, imageViewSize.height)];
        self.cardImage.contentMode = UIViewContentModeScaleAspectFit;;
        
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, self.cardImage.frame.origin.y+self.cardImage.bounds.size.height+DEFAULT_SPACING, ALERT_WIDTH, 40.0)];
        
        //CARD TITLE & DESCRIPTION
        self.cardTitle = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_SPACING, 0.0, ALERT_WIDTH-(DEFAULT_SPACING*2), 20.0)];
        self.cardDescription = [[UILabel alloc] initWithFrame:CGRectMake(DEFAULT_SPACING, self.cardTitle.frame.origin.y+self.cardTitle.bounds.size.height+(DEFAULT_SPACING/2), ALERT_WIDTH-(DEFAULT_SPACING*2), 20.0)];
        
        self.cardTitle.numberOfLines = 0;
        self.cardDescription.numberOfLines = 0;
        
        self.cardTitle.textAlignment = NSTextAlignmentCenter;
        self.cardDescription.textAlignment = NSTextAlignmentCenter;
		
		[self.cardTitle setFont:[UIFont boldSystemFontOfSize:18]];
        
        //CLOSE BUTTON
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
        closeButton.tag = 1;
        [closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateHighlighted];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateSelected];
        //Add action to the close button
        [closeButton addTarget:self action:@selector(closeAlert:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        //CARD HEADER
        CGSize labelSize = CGSizeMake(ALERT_WIDTH*0.60, 28.0);
        self.cardHeader = [[UILabel alloc] initWithFrame:CGRectMake(header.bounds.size.width/2-labelSize.width/2, 10.0, labelSize.width, labelSize.height)];
        self.cardHeader.text = NSLocalizedString(@"Congratulations!", nil); //default header
        self.cardHeader.textColor = [UIColor whiteColor];
        self.cardHeader.textAlignment = NSTextAlignmentCenter;
        self.cardHeader.numberOfLines = 1;
        self.cardHeader.lineBreakMode = NSLineBreakByTruncatingTail;
        
        
        
        //Building Header
        [header addSubview:closeButton];
        [header addSubview:self.cardHeader];
        [containerView addSubview:header];
        
        
        //Building Content
        [containerView addSubview:self.cardImage];
        [self.scrollView addSubview:self.cardTitle];
        [self.scrollView addSubview:self.cardDescription];
        [containerView addSubview:self.scrollView];
		
		self.containerView.layer.cornerRadius = 10;
		self.containerView.clipsToBounds = YES;
		
        
        //Adding the container view to the alert view
        [self setContainerView:containerView];
        
        //Adds the share button to the alert view
        [self setButtonTitles:@[NSLocalizedString(@"Share with your friends!", nil)]];
    }
    return self;
}

- (void) closeAlert:(id)sender {
    UIButton *button = (UIButton*)sender;
    CustomIOS7AlertView *cardDescription = (CustomIOS7AlertView*)button.superview.superview.superview.superview;
    [cardDescription close];
}

/**
 *  Show the card description with an optional custom top header string, image, title and description.
 *
 *  @param header top header of the alert
 *  @param image image that will be displayed on the center of the alert
 *  @param title title of the achievement, displayed below the image
 *  @param description description of the achievement, displayed below the title. May scroll if too long.
 *
 *  @author Roger Oba
 *
 */
- (void) showAlertWithHeader:(NSString*) header image:(UIImage*)image title:(NSString*)title description:(NSString*)description {
    if (image && title && description) {
        if (header) {
            self.cardHeader.text = header;
        }
        self.cardImage.image = image;
        self.cardTitle.text = title;
        self.cardDescription.text = description;
        
        [self.cardTitle sizeToFit];
        [self.cardDescription sizeToFit];
        
        //Update labels origin (x,y)
        self.cardTitle.frame = CGRectMake(ALERT_WIDTH/2-self.cardTitle.frame.size.width/2,
                                                 0.0f,
                                                 self.cardTitle.frame.size.width,
                                                 self.cardTitle.frame.size.height);
        
        self.cardDescription.frame = CGRectMake(ALERT_WIDTH/2-self.cardDescription.frame.size.width/2,
                                                       self.cardTitle.frame.origin.y+self.cardTitle.bounds.size.height+10.0,
                                                       self.cardDescription.frame.size.width,
                                                       self.cardDescription.frame.size.height);
        
        self.scrollView.frame = CGRectMake(0.0f,
                                           self.cardImage.frame.origin.y+self.cardImage.frame.size.height+DEFAULT_SPACING,
                                           ALERT_WIDTH,
                                           self.cardDescription.frame.origin.y+self.cardDescription.frame.size.height+DEFAULT_SPACING);
        
        self.scrollView.showsVerticalScrollIndicator = NO;
        
        float screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        //if messages are small
        if (self.scrollView.frame.origin.y+self.scrollView.frame.size.height+DEFAULT_SPACING*2+BUTTON_HEIGHT < screenHeight) {
            //Updates the Container View to fit the desired height
            self.containerView.frame = CGRectMake(self.containerView.frame.origin.x,
                                                  self.containerView.frame.origin.y,
                                                  self.containerView.frame.size.width,
                                                  self.scrollView.frame.origin.y+self.scrollView.frame.size.height+DEFAULT_SPACING-20.0);
            
            //Determines the scrollable area (without extra bottom space)
            [self.scrollView setContentSize:CGSizeMake(ALERT_WIDTH,
                                                       self.cardDescription.frame.origin.y+self.cardDescription.frame.size.height+DEFAULT_SPACING)];
        }
        //else messages are too big
        else {
            //Updates the scrollView Frame
            self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
                                               self.scrollView.frame.origin.y,
                                               self.scrollView.frame.size.width,
                                               screenHeight-(DEFAULT_SPACING*2)-BUTTON_HEIGHT-(self.cardImage.frame.origin.y+self.cardImage.frame.size.height));
            
            //Limits the Container View to fit the screen size
            self.containerView.frame = CGRectMake(self.containerView.frame.origin.x,
                                                  self.containerView.frame.origin.y,
                                                  self.containerView.frame.size.width,
                                                  screenHeight-40-BUTTON_HEIGHT);
            //Determines the scrollable area (with extra bottom space)
            [self.scrollView setContentSize:CGSizeMake(ALERT_WIDTH,
                                                       self.cardDescription.frame.origin.y+self.cardDescription.frame.size.height+DEFAULT_SPACING*2)];
            
        }
        [self show];
    }
    else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Description", @"No card   description alert") message:NSLocalizedString(@"There's no detailed description for this card. Please edit your custom deck and add some description to the cards.", @"No card description alert") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        NSLog(@"Called method with invalid values: header: %@ image: %@ title: %@ description: %@",header,image,title,description);
    }
}


/* //Acabei não utilizando, mas deixa aqui que pode vir a ser útil
- (int) numberOfLinesOfLabel:(UILabel *)label {
    CGSize maxSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
    
    CGRect labelRect = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];
    
    NSLog(@"%f",ceil(labelRect.size.height / label.font.lineHeight));
    return ceil(labelRect.size.height / label.font.lineHeight);
}*/

@end
