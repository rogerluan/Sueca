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

#import "ZLSwipeableView.h"
#import "SuecaSwipeDeterminator.h"
#import "CardView.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface GameViewController () <UIGestureRecognizerDelegate,CustomIOS7AlertViewDelegate,ZLSwipeableViewDataSource, ZLSwipeableViewDelegate,ZLSwipeableViewAnimator>

@property (weak, nonatomic) IBOutlet UIButton *shuffleDeckButton;
@property (weak, nonatomic) IBOutlet UIButton *drawCardButton;
@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet UIView *cardContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameLogo;

@property (strong, nonatomic) ZLSwipeableView *swipeableView;

@property (strong,nonatomic) Card *displayCard;
@property (strong,nonatomic) UIImageView *previousCard;

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
    
    [self setupViewsLayout];
	
	[self.cardContainerView layoutIfNeeded];
	[self.cardContainerView updateConstraintsIfNeeded];
	ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:self.cardContainerView.frame];
	self.swipeableView = swipeableView;
	self.swipeableView.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.204];
	self.swipeableView.numberOfActiveViews = 10;
	self.swipeableView.numberOfHistoryItem = 1;
	[self.cardContainerView addSubview:self.swipeableView];
	
	self.swipeableView.dataSource = self;
	self.swipeableView.delegate = self;
	self.swipeableView.viewAnimator = self;
	self.swipeableView.swipingDeterminator = [SuecaSwipeDeterminator new];
	
	//The code below changes the area where the next card will spawn from.
	self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *metrics = @{};
	[self.cardContainerView addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"|-80-[swipeableView]-80-|"
							   options:0
							   metrics:metrics
							   views:NSDictionaryOfVariableBindings(swipeableView)]];
	
	[self.cardContainerView addConstraints:[NSLayoutConstraint
							   constraintsWithVisualFormat:@"V:|-30-[swipeableView]-80-|"
							   options:0
							   metrics:metrics
							   views:NSDictionaryOfVariableBindings(swipeableView)]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.gameManager refreshDeckArray];
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
		Card *card = [(CardView*)[self.swipeableView.history lastObject] card];
		NSLog(@"history: %@, card: %@",self.swipeableView.history,card);
		[self.ruleButton setTitle:NSLocalizedString(card.cardRule,nil) forState:UIControlStateNormal];
	}
	if ([super respondsToSelector:@selector(motionEnded:withEvent:)])
		[super motionEnded:motion withEvent:event];
}

#pragma mark - IBActions -

- (IBAction)displayCardDescription:(id)sender {
    if ([self.cardContainerView.subviews count]) {
        CardDescriptionView *descriptionView = [[CardDescriptionView alloc] init];
        [descriptionView showAlertWithHeader:NSLocalizedString(@"#Sueca", @"Card description popover header") image:[UIImage imageNamed:self.displayCard.cardName] title:NSLocalizedString(self.displayCard.cardRule,nil) description:NSLocalizedString(self.displayCard.cardDescription,nil) sender:self];
        descriptionView.delegate = self;
    }
}

- (IBAction)sortCard:(id)sender {
    [AnalyticsManager increaseGlobalSortCount];
    [self sortCard];
}

- (IBAction)shuffleButton:(id)sender {
    [AnalyticsManager increaseGlobalShuffleCount];
    [self shuffle];
}

/**
 *  Calls game manager to sort a new card, displays and animates it.
 *  @author Roger Oba
 */
- (void)sortCard {
    
    [self.soundManager playRandomCardSlideSoundFX];
    self.displayCard = [self.gameManager newCard];
    
    /* Animation initialization and execution */
    int containerWidth = self.cardContainerView.frame.size.width;
    int containerHeight = self.cardContainerView.frame.size.height;
    int indexX = arc4random()%(containerWidth-119);
    int indexY = arc4random()%(containerHeight-177);
    
    CGRect newFrame = CGRectMake(indexX,indexY,119,177);
    UIImageView *cardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.displayCard.cardName]];
    cardImage.layer.anchorPoint = CGPointMake(0.5,0.5);
    CGAffineTransform transform = CGAffineTransformMakeRotation(2*M_PI);
    
    //Setting the previousCard
    if (self.previousCard) {
        for (UIGestureRecognizer *recognizer in self.previousCard.gestureRecognizers) {
            [self.previousCard removeGestureRecognizer:recognizer];
        }
    }
    self.previousCard = cardImage;
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         cardImage.transform = transform;
                         cardImage.frame = newFrame;
                     }
                     completion:nil];
    
    for (UIImageView *view in [self.cardContainerView subviews]) {
        if (![view isEqual:self.gameLogo] ) {
            view.alpha/=1.2;
        }
        if (view.alpha <= 0.012579) { //removes invisible images
            [view removeFromSuperview];
        }
    }
    
    [self.cardContainerView addSubview:cardImage];
    
    /* Shows the rule on screen */
    [self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateNormal];
    
    if (!self.displayCard.cardDescription && [[NSUserDefaults standardUserDefaults] integerForKey:@"showNoDescriptionWarning"] == 2) {
        //user opted-out warning message, so we disable the button
        [self.ruleButton setUserInteractionEnabled:NO];
    }
}

/**
 *  Remove all cards on the screen.
 *  @author Roger Oba
 */
- (void)clearTable {
    for (UIImageView *view in [self.cardContainerView subviews]) {
        if (![view isEqual:self.gameLogo] ) {
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 view.alpha = 0;
                             }
                             completion: ^(BOOL finished){
                                 [view removeFromSuperview];
                             }];
        }
    }
    [self.ruleButton setTitle:@"" forState:UIControlStateNormal];
}

/**
 *  Method that do all the stuff related with the shuffling
 *  @author Roger Oba
 */
- (void)shuffle {
    [self.soundManager playShuffleSoundFX];
    [self clearTable];
    [self.gameManager refreshDeckArray];
}

#pragma mark - Appearance -

/**
 *  Layouts the buttons accordingly, setting corners and borders.
 *  @author Roger Oba
 */
- (void)setupViewsLayout {
    self.drawCardButton.layer.cornerRadius = self.drawCardButton.frame.size.width/10;
    self.drawCardButton.clipsToBounds = YES;
    
    self.shuffleDeckButton.layer.cornerRadius = self.shuffleDeckButton.frame.size.width/10;
    self.shuffleDeckButton.clipsToBounds = YES;
    
    [self.ruleButton setTitle:@"" forState:UIControlStateNormal];
    [self.ruleButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
    [self.ruleButton.titleLabel setNumberOfLines: 2];
    
    self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    [AppearanceManager addShadowToLayer:self.ruleButton.layer opacity:0.9 radius:10.0];
    
    //to-do: fix this later. Recreate the background images and Use bitcode.
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    } else {
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    }
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
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypeAirDrop];
    [alertView close];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - ZLSwipeableView Methods - 

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
	//updates the display card to reflect the actual top card, and update the rule button
	self.displayCard = [(CardView*)swipeableView.topView card];
	[self.ruleButton setTitle:NSLocalizedString(self.displayCard.cardRule,nil) forState:UIControlStateNormal];
	
	CardView *view = [CardView new];
	view.card = [self.gameManager newCard];
	
	if ([self.gameManager.deck.isEditable isEqualToNumber:@1]) {
//		NSInteger cardHeight = self.cardContainerView.frame.size.height;
//		NSInteger cardWidth = 181/(258/cardHeight);
//		view.frame = CGRectMake(0, 0, cardWidth, cardHeight);
		view.frame = CGRectMake(0, 0, 181/2, 258/2);
	} else {
//		NSInteger cardHeight = self.cardContainerView.frame.size.height;
//		NSInteger cardWidth = 391/(600/cardHeight);
//		view.frame = CGRectMake(0, 0, cardWidth, cardHeight);
		view.frame = CGRectMake(0, 0, 391/2, 600/2);
	}
//	NSLog(@"%@ view frame",NSStringFromCGRect(view.frame));
//	view.backgroundColor = [UIColor colorWithRed:0.194 green:0.509 blue:0.852 alpha:0.359];
	return view;
}

#pragma mark - ZLSwipeableViewDelegate

- (void)swipeableView:(ZLSwipeableView *)swipeableView
		 didSwipeView:(UIView *)view
		  inDirection:(ZLSwipeableViewDirection)direction {
	NSLog(@"did swipe in direction: %zd", direction);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView didCancelSwipe:(UIView *)view {
	NSLog(@"did cancel swipe");
}
//
//- (void)swipeableView:(ZLSwipeableView *)swipeableView didStartSwipingView:(UIView *)view atLocation:(CGPoint)location {
//	[[ViewManager new] setStateSnapping:CGPointMake(200, 200)];
//}

#pragma mark - ZLSwipeableView Animator

- (void)animateView:(UIView *)view index:(NSUInteger)index views:(NSArray<UIView *> *)views swipeableView:(ZLSwipeableView *)swipeableView {
	CGFloat degree = sin(0.5 * index);
	NSTimeInterval duration = 0.4;
	CGPoint offset = CGPointMake(0, CGRectGetHeight(swipeableView.bounds) * 0.3);
	CGPoint translation = CGPointMake(degree * 10.0, -(index * 3.0));
	[self rotateAndTranslateView:view
					   forDegree:degree
					 translation:translation
						duration:duration
			  atOffsetFromCenter:offset
				   swipeableView:swipeableView];
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
	return degrees * M_PI / 180;
}

- (void)rotateAndTranslateView:(UIView *)view
					 forDegree:(float)degree
				   translation:(CGPoint)translation
					  duration:(NSTimeInterval)duration
			atOffsetFromCenter:(CGPoint)offset
				 swipeableView:(ZLSwipeableView *)swipeableView {
	float rotationRadian = [self degreesToRadians:degree];
	[UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 view.center = [swipeableView convertPoint:swipeableView.center
														  fromView:swipeableView.superview];
						 CGAffineTransform transform =
						 CGAffineTransformMakeTranslation(offset.x, offset.y);
						 transform = CGAffineTransformRotate(transform, rotationRadian);
						 transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y);
						 transform =
						 CGAffineTransformTranslate(transform, translation.x, translation.y);
						 view.transform = transform;
					 }
					 completion:nil];
}

@end
