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

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

@interface GameViewController () <UIGestureRecognizerDelegate,CustomIOS7AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shuffleDeckButton;
@property (weak, nonatomic) IBOutlet UIButton *drawCardButton;
@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (strong, nonatomic) IBOutlet UIView *cardContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameLogo;

@property (strong,nonatomic) Card *displayCard;
@property (strong,nonatomic) UIImageView *previousCard;

@property (strong, nonatomic) SoundManager *soundManager;
@property (strong, nonatomic) GameManager *gameManager;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //to-do: update GameVC to use factoryVC
    self.soundManager = [SoundManager new];
    self.gameManager = [GameManager new];
    
    [self setupViewsLayout];
}

- (IBAction)displayCardDescription:(id)sender {
    if ([self.cardContainerView.subviews count]) {
        CardDescriptionView *descriptionView = [[CardDescriptionView alloc] init];
        [descriptionView showAlertWithHeader:NSLocalizedString(@"#Sueca", @"Card description popover header") image:[UIImage imageNamed:self.displayCard.cardName] title:NSLocalizedString(self.displayCard.cardRule,nil) description:NSLocalizedString(self.displayCard.cardDescription,nil) sender:self];
        descriptionView.delegate = self;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gameManager refreshDeckArray];
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

#pragma mark - Style

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

@end
