//
//  GameViewController.m
//  Sueca
//
//  Created by Roger Oba on 25/10/13.
//  Copyright (c) 2013 Roger Oba. All rights reserved.
//

#import "GameViewController.h"
#import "CardDescriptionView.h"
#import "AppearanceHelper.h"
#import "SoundManager.h"
#import "GameManager.h"
#import "NotificationManager.h"
#import "ShareViewController.h"

@interface GameViewController () <UIGestureRecognizerDelegate, CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet ZLSwipeableView *swipeableView;

@property (assign) BOOL shouldUpdateDeck;
@property (strong, nonatomic) Card *displayCard;

@property (strong, nonatomic) SoundManager *soundManager;
@property (strong, nonatomic) GameManager *gameManager;
@property (strong, nonatomic) NotificationManager *notificationManager;

@property (assign) BOOL shouldSwipe;

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
	self.gameManager = [GameManager sharedInstance];
	self.notificationManager = [NotificationManager new];
	self.swipeableView.numberOfActiveViews = 10;
	self.swipeableView.numberOfHistoryItem = 1;
	self.swipeableView.viewAnimator = [SuecaViewAnimator new];
	self.swipeableView.swipingDeterminator = [SuecaSwipeDeterminator new];
	[self.swipeableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSwipeableView:)]];
	self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
	self.shouldSwipe = YES;
	[self registerForNotification];
}

- (void)dealloc {
	[self unregisterForNotification];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self updateRuleLabel];

	if (self.shouldUpdateDeck) {
		[self updateDeck];
	}
	
	[AnalyticsManager logContentViewEvent:AnalyticsEventViewGameVC contentType:@"UIViewController"];
}

- (void)viewDidLayoutSubviews {
	[self.swipeableView loadViewsIfNeeded];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - IBActions -

- (IBAction)displayCardDescription:(id)sender {
    if (self.swipeableView.topView) {
		if ([self.displayCard.cardName isEqualToString:@"promoCard"]) {
			if (![[NSUserDefaults standardUserDefaults] boolForKey:@"requestedNotificationPermission"]) {
				__weak typeof(self) weakSelf = self;
				[self.notificationManager registerForPromotionsWithCompletion:^(NSError *error) {
					if (!error) {
						NSLog(@"Successfully registered for promotions (in CloudKit).");
					} else {
						NSLog(@"Error when trying to register for promotions. Error: %@", error);
						dispatch_async(dispatch_get_main_queue(), ^(void) {
							[weakSelf presentViewController:[ErrorManager alertFromError:error] animated:YES completion:nil];
						});
					}
				}];
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
			}
			[AnalyticsManager logEvent:AnalyticsEventPushRegistrationButton];
		} else {
			CardDescriptionView *descriptionView = [[CardDescriptionView alloc] init];
			NSString *imagePath = [NSString stringWithFormat:@"%@-TableOptimized", self.displayCard.cardName];
			[descriptionView showAlertWithHeader:NSLocalizedString(@"#Sueca", @"Card description popover header") image:[UIImage imageNamed:imagePath] title:NSLocalizedString(self.displayCard.cardRule,nil) description:NSLocalizedString(self.displayCard.cardDescription,nil) sender:self];
			descriptionView.delegate = self;
			[AnalyticsManager logContentViewEvent:AnalyticsEventCardDescriptionView contentType:@"CardDescriptionView" customAttributes:self.displayCard.attributes];
		}
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.subtype == UIEventSubtypeMotionShake) {
		if (self.swipeableView.history.count > 0) {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Undo Action", @"UIAlertController title") message:NSLocalizedString(@"You shaked your device, so the previous card will be rewinded. Only the last card can be rewinded. Are you sure you want to do this?", nil) preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rewind Card", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				[self.swipeableView rewind];
				[self updateRuleLabel];
				[AnalyticsManager logEvent:AnalyticsEventShakeAcceptButton withAttributes:self.displayCard.attributes];
			}];
			UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
				[AnalyticsManager logEvent:AnalyticsEventShakeCancelButton withAttributes:self.displayCard.attributes];
			}];
			[alert addAction:action];
			[alert addAction:cancelAction];
			[self presentViewController:alert animated:YES completion:nil];
		}
		[AnalyticsManager logEvent:AnalyticsEventDidShakeDevice withAttributes:self.displayCard.attributes];
	}
	if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
		[super motionEnded:motion withEvent:event];
	}
}

- (void)updateDeck {
	self.shouldUpdateDeck = NO;
	[self.soundManager playShuffleSoundFX];
	[self.gameManager refreshDeckArray];
	[self.swipeableView discardAllViews];
	[self.swipeableView loadViewsIfNeeded];
	[self updateRuleLabel];
}

- (void)tappedSwipeableView:(UITapGestureRecognizer *)tap {
	if (self.shouldSwipe) {
		NSInteger swipeDirection = [[NSUserDefaults standardUserDefaults] integerForKey:@"swipeDirection"];
		switch (swipeDirection) {
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
		if (swipeDirection >= 3) {
			swipeDirection = 0;
		} else {
			swipeDirection++;
		}
		[[NSUserDefaults standardUserDefaults] setInteger:swipeDirection forKey:@"swipeDirection"];
		[AnalyticsManager logEvent:AnalyticsEventTapCardGesture withAttributes:self.displayCard.attributes];
	} else {
		[self.swipeableView.topView.layer addAnimation:[AppearanceHelper shakeAnimation] forKey:@""];
		self.swipeableView.topView.transform = CGAffineTransformIdentity;
		[AnalyticsManager logEvent:AnalyticsEventTapCardDuringTimer withAttributes:self.displayCard.attributes];
	}
}

#pragma mark - Appearance -

- (void)setupViewsLayout {
    [self.ruleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.ruleButton.titleLabel setNumberOfLines:2];
	[self.ruleButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[self.ruleButton.titleLabel setMinimumScaleFactor:15/25];
    [AppearanceHelper addShadowToLayer:self.ruleButton.layer opacity:0.9 radius:10.0];
}

- (void)updateRuleLabel {
	CardView *cardView = (CardView *)[self.swipeableView topView];
	self.displayCard = [cardView card];
	if ([self.displayCard.cardName isEqualToString:@"promoCard"]) {
		self.swipeableView.allowedDirection = ZLSwipeableViewDirectionNone;
		self.shouldSwipe = NO;
		[UIView animateWithDuration:5
							  delay:0
							options:UIViewAnimationOptionCurveLinear
						 animations:^{
							 [CATransaction setCompletionBlock:^{
								 self.swipeableView.allowedDirection = ZLSwipeableViewDirectionAll;
								 self.shouldSwipe = YES;
								 [UIView animateWithDuration:1 animations:^{
									 cardView.progressBar.alpha = 0;
								 }];
							 }];
							 [cardView.progressBar setProgress:1 animated:YES];
						 } completion:nil];
		[AnalyticsManager logContentViewEvent:AnalyticsEventViewPromoCard contentType:@"Custom Card"];
	}
	//to-do: the line below may cause unexpected strings if the user set a text that represents localized string accidentally.
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule, nil) forState:UIControlStateNormal];
}

#pragma mark - CustomIOS7dialogButton Delegate Method

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView close];
	ShareViewController *activityViewController = [ShareViewController initWithCard:self.displayCard];
    [self presentViewController:activityViewController animated:YES completion:nil];
	[AnalyticsManager logContentViewEvent:AnalyticsEventShareActivityView contentType:@"UIActivityController" customAttributes:self.displayCard.attributes];
}

#pragma mark - ZLSwipeableView Methods

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
	CardView *view = [[CardView alloc] initWithFrame:self.swipeableView.bounds];
	Card *card = [self.gameManager newCard];
	view.card = card;
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

#pragma mark - Notification Center -

- (void)registerForNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationUpdateDeck object:nil];
}

- (void)unregisterForNotification {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)notification {
	if ([notification.name isEqualToString:SuecaNotificationUpdateDeck]) {
		self.shouldUpdateDeck = YES;
	}
}

@end
