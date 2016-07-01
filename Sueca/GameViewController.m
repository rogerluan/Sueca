//
//  GameViewController.m
//  Sueca
//
//  Created by Roger Oba on 25/10/13.
//  Copyright (c) 2013 Roger Oba. All rights reserved.
//

#import "GameViewController.h"

#import "CardDescriptionView.h"
#import "AppearanceManager.h"
#import "AnalyticsManager.h"
#import "SuecaSwipeDeterminator.h"
#import "SuecaViewAnimator.h"
#import "CardView.h"
#import "SoundManager.h"
#import "GameManager.h"

@interface GameViewController () <UIGestureRecognizerDelegate, CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet ZLSwipeableView *swipeableView;

@property (strong, nonatomic) Deck *localDeck; //only used to check if the deck has changed.
@property (strong, nonatomic) Card *displayCard;

@property (strong, nonatomic) SoundManager *soundManager;
@property (strong, nonatomic) GameManager *gameManager;

@end

@implementation GameViewController

#pragma mark - Lifecycle - 

- (void)viewDidLoad {
	[self setup];
    [super viewDidLoad];
    [self setupViewsLayout];	
}

- (void)setup {
	self.soundManager = [SoundManager new];
	self.gameManager = [GameManager new];
	self.localDeck = self.gameManager.deck;
	self.swipeableView.numberOfActiveViews = 10;
	self.swipeableView.numberOfHistoryItem = 1;
	self.swipeableView.viewAnimator = [SuecaViewAnimator new];
	self.swipeableView.swipingDeterminator = [SuecaSwipeDeterminator new];
	[self.swipeableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSwipeableView:)]];
	self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateRuleLabel];
	
	if (![self.localDeck isEqual:self.gameManager.deck]) {
		[self changeDeck];
	}
	
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewGameVC contentType:@"UIViewController"];
}

- (void)viewDidLayoutSubviews {
	[self.swipeableView loadViewsIfNeeded];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.subtype == UIEventSubtypeMotionShake) {
		[self.swipeableView rewind];
		[self updateRuleLabel];
		NSDictionary *attributes = @{@"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
		[AnalyticsManager logEvent:AnalyticsEventDidShakeDevice withAttributes:attributes];
	}
	if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
		[super motionEnded:motion withEvent:event];
	}
}

#pragma mark - IBActions -

- (IBAction)displayCardDescription:(id)sender {
    if (self.swipeableView.topView) {
        CardDescriptionView *descriptionView = [[CardDescriptionView alloc] init];
        [descriptionView showAlertWithHeader:NSLocalizedString(@"#Sueca", @"Card description popover header") image:[UIImage imageNamed:self.displayCard.cardName] title:NSLocalizedString(self.displayCard.cardRule,nil) description:NSLocalizedString(self.displayCard.cardDescription,nil) sender:self];
        descriptionView.delegate = self;
		NSDictionary *attributes = @{@"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
		[AnalyticsManager logContentViewEvent:AnalyticsEventCardDescriptionView contentType:@"CardDescriptionView" customAttributes:attributes];
    }
}

- (void)changeDeck {
	self.localDeck = self.gameManager.deck;
	[self.soundManager playShuffleSoundFX];
	[self.gameManager refreshDeckArray];
	[self.swipeableView discardAllViews];
	[self.swipeableView loadViewsIfNeeded];
	[self updateRuleLabel];
}

- (void)tappedSwipeableView:(UITapGestureRecognizer *)tap {
	NSInteger random = arc4random_uniform(4);
	NSLog(@"random: %ld", (long)random);
	switch (random) {
		case 0: [self.swipeableView swipeTopViewToLeft];
			break;
		case 1: [self.swipeableView swipeTopViewToUp];
			break;
		case 2: [self.swipeableView swipeTopViewToRight];
			break;
		case 3: [self.swipeableView swipeTopViewToDown];
			break;
		default: [self.swipeableView swipeTopViewToRight];
	}
	
	NSDictionary *attributes = @{@"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
	[AnalyticsManager logEvent:AnalyticsEventTapCardGesture withAttributes:attributes];
}

#pragma mark - Appearance -

- (void)setupViewsLayout {
    [self.ruleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.ruleButton.titleLabel setNumberOfLines:2];
    
    self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
	
    [AppearanceManager addShadowToLayer:self.ruleButton.layer opacity:0.9 radius:10.0];
}

- (void)updateRuleLabel {
	self.displayCard = [(CardView *)[self.swipeableView topView] card];
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule, nil) forState:UIControlStateNormal];
}

#pragma mark - CustomIOS7dialogButton Delegate Method

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *sharingString = [NSString stringWithFormat: NSLocalizedString(@"Everyone's drinking shots on Sueca Drinking Game. Come over to have some fun! #sueca", @"Activity View Sharing String")];
    UIImage *sharingImage = nil;
    
    if (self.displayCard.deck.isDefault) {
        sharingImage = [UIImage imageNamed:self.displayCard.cardName];
    } else {
        sharingImage = [UIImage imageNamed:@"sharingSuecaLogoImage"];
    }

    NSURL *sharingURL = [NSURL URLWithString:@"bit.ly/1JwDmry"];
    NSString *fullSharingString = [NSString stringWithFormat:@"%@ %@", sharingString, sharingURL];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[fullSharingString, sharingImage, sharingURL]
                                      applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypeAirDrop];
	
	if ([activityViewController respondsToSelector:@selector(setCompletionWithItemsHandler:)]) {
		[activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
			NSDictionary *attributes = @{@"activityType":activityType, @"completed":[NSNumber numberWithBool:completed], @"error":activityError.localizedDescription, @"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
			[Answers logShareWithMethod:activityType contentName:AnalyticsEventDidShareCard contentType:nil contentId:nil customAttributes:attributes];
		}];
	} else {
		[activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
			NSDictionary *attributes = @{@"activityType":activityType, @"completed":[NSNumber numberWithBool:completed], @"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
			[Answers logShareWithMethod:activityType contentName:AnalyticsEventDidShareCard contentType:nil contentId:nil customAttributes:attributes];
		}];
	}
	
    [alertView close];
    [self presentViewController:activityViewController animated:YES completion:nil];
	
	NSDictionary *attributes = @{@"Card Name":self.displayCard.cardName,
								 @"Card Rule":self.displayCard.cardRule,
								 @"Card Description":self.displayCard.cardDescription};
	[AnalyticsManager logContentViewEvent:AnalyticsEventShareActivityView contentType:@"UIActivityController" customAttributes:attributes];
}

#pragma mark - ZLSwipeableView Methods

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
	//updates the display card to reflect the actual top card, and update the rule button
	CardView *view = [[CardView alloc] initWithFrame:self.swipeableView.bounds];
	view.card = [self.gameManager newCard];
	return view;
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView didSwipeView:(UIView *)view inDirection:(ZLSwipeableViewDirection)direction {
	[self.soundManager playRandomCardSlideSoundFX];
	[AnalyticsManager increaseGlobalSortCount];
	[self updateRuleLabel];
	NSDictionary *attributes = @{@"Direction":[NSNumber numberWithInteger:direction]};
	[AnalyticsManager logEvent:AnalyticsEventDidSwipeCard withAttributes:attributes];
}

@end
