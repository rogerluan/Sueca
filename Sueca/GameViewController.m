//
//  GameViewController.m
//  Sueca
//
//  Created by Roger Oba on 25/10/13.
//  Copyright (c) 2013 Roger Oba. All rights reserved.
//

#import "GameViewController.h"

#import "CardDescriptionView.h"
#import "JBWhatsAppActivity.h"
#import "AppearanceManager.h"
#import "SoundManager.h"
#import "AnalyticsManager.h"
#import "GameManager.h"

#import "SuecaSwipeDeterminator.h"
#import "SuecaViewAnimator.h"
#import "CardView.h"

@interface GameViewController () <UIGestureRecognizerDelegate,CustomIOS7AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet ZLSwipeableView *swipeableView;

@property (strong, nonatomic) Deck *localDeck; //only used to check if the deck has changed.
@property (strong, nonatomic) Card *displayCard;
@property (strong, nonatomic) UIImageView *previousCard;

@property (strong, nonatomic) SoundManager *soundManager;
@property (strong, nonatomic) GameManager *gameManager;

@end

@implementation GameViewController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //to-do: update GameVC to use factoryVC
    self.soundManager = [SoundManager new];
    self.gameManager = [GameManager new];
	self.localDeck = self.gameManager.deck;
    
    [self setupViewsLayout];
	
	
//	ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
//	self.swipeableView = swipeableView;
//	[self.view addSubview:self.swipeableView];
	
	self.swipeableView.numberOfActiveViews = 10;
	self.swipeableView.numberOfHistoryItem = 1;
	self.swipeableView.viewAnimator = [SuecaViewAnimator new];
	self.swipeableView.swipingDeterminator = [SuecaSwipeDeterminator new];
//	UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer alloc] initWithTarget:AnalyticsManager action:<#(nullable SEL)#>
//	self.swipeableView addGestureRecognizer:

	NSLog(@"swipeableView frame: %@",NSStringFromCGRect(self.swipeableView.frame));
	
	//The code below changes the area where the next card will spawn from.
	self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
//	NSDictionary *metrics = @{};
//	ZLSwipeableView *swipeableView = self.swipeableView;
//	[self.view addConstraints:[NSLayoutConstraint
//							   constraintsWithVisualFormat:@"|-80-[swipeableView]-80-|"
//							   options:0
//							   metrics:metrics
//							   views:NSDictionaryOfVariableBindings(self.swipeableView)]];
//	
//	[self.view addConstraints:[NSLayoutConstraint
//							   constraintsWithVisualFormat:@"V:|-30-[swipeableView]-80-|"
//							   options:0
//							   metrics:metrics
//							   views:NSDictionaryOfVariableBindings(self.swipeableView)]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateRuleLabel];
	
	if (![self.localDeck isEqual:self.gameManager.deck]) {
		[self changeDeck];
	}
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

#pragma mark - Appearance -

- (void)setupViewsLayout {
    [self.ruleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.ruleButton.titleLabel setNumberOfLines:2];
    
    self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
	
    [AppearanceManager addShadowToLayer:self.ruleButton.layer opacity:0.9 radius:10.0];
}

- (void)updateRuleLabel {
	self.displayCard = [(CardView*)[self.swipeableView topView] card];
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateNormal];
}

#pragma mark - CustomIOS7dialogButton Delegate Method

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *sharingString = [NSString stringWithFormat: NSLocalizedString(@"Everyone's drinking shots on Sueca Drinking Game. Come over to have some fun! #sueca", @"Activity View Sharing String")];
    UIImage *sharingImage = nil;
    
    if ([self.displayCard.deck.isEditable isEqualToNumber:@NO]) {
        sharingImage = [UIImage imageNamed:self.displayCard.cardName];
    } else {
        sharingImage = [UIImage imageNamed:@"sharingSuecaLogoImage"];
    }

    NSURL *sharingURL = [NSURL URLWithString:@"bit.ly/1JwDmry"];
    NSString *fullSharingString = [NSString stringWithFormat:@"%@ %@",sharingString,sharingURL];
    WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:fullSharingString forABID:nil];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[fullSharingString,sharingImage,sharingURL,whatsappMsg]
                                      applicationActivities:@[[[JBWhatsAppActivity alloc] init]]];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypeAirDrop];
    [alertView close];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - ZLSwipeableView Methods - 

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
	//updates the display card to reflect the actual top card, and update the rule button
	CardView *view = [[CardView alloc] initWithFrame:self.swipeableView.frame];
	view.card = [self.gameManager newCard];
	return view;
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
		 didSwipeView:(UIView *)view
		  inDirection:(ZLSwipeableViewDirection)direction {
	
	[self.soundManager playRandomCardSlideSoundFX];
	[AnalyticsManager increaseGlobalSortCount];
	[self updateRuleLabel];
}

#pragma mark - Analytics

- (void)tappedSwipeableView {
	NSDictionary *attributes = @{@"Card Name":self.displayCard.cardName, @"Card Rule":self.displayCard.cardRule, @"Card Description":self.displayCard.cardDescription};
	[AnalyticsManager logEvent:AnalyticsGestureEventTapCard withAttributes:attributes];
}

@end
