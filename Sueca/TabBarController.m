//
//  TabBarController.m
//  Sueca
//
//  Created by Roger Luan on 4/25/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "TabBarController.h"
#import "iRateCoordinator.h"
#import "iVersionCoordinator.h"
#import "AnalyticsManager.h"
#import "GameViewController.h"
#import "Constants.h"
#import "GameManager.h"
#import "TSBlurView.h"

#import <TSMessages/TSMessageView.h>

@interface TabBarController () <TSMessageViewProtocol>

@property (strong, nonatomic) GameManager *gameManager;
@property (strong, nonatomic) IBOutlet iRateCoordinator *ratingCoordinator;
@property (strong, nonatomic) IBOutlet iVersionCoordinator *versioningCoordinator;

@end

@implementation TabBarController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gameManager = [GameManager new];
    [self registerForNotification];
	
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == ShuffleDeckWarningNeverDecided) {
        [[NSUserDefaults standardUserDefaults] setInteger:ShuffleDeckWarningDisplay forKey:@"showShuffledDeckWarning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Deck createDefaultDeck];
    } else {
        [self performSelector:@selector(showWelcomeBackMessage) withObject:nil afterDelay:3.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[self unregisterForNotification];
}

#pragma mark - Welcome Back Message -

- (void)showWelcomeBackMessage {
    
    NSString *welcomeBackMessage = [self randomWelcomeBackMessage];
    NSString *buttonTitle = nil;
    if ([welcomeBackMessage rangeOfString:@"😇"].location != NSNotFound) {
        buttonTitle = NSLocalizedString(@"Review", @"Welcome Back Message Button Title");
    }
    
    [TSMessage setDelegate:self];
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Welcome Back!", @"TSMessage Welcome Back Title")
                                       subtitle:welcomeBackMessage
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
									   callback:^{
										   NSMutableDictionary *attributes = [NSMutableDictionary new];
										   if (welcomeBackMessage) {
											   [attributes addEntriesFromDictionary:@{@"Notification Message":welcomeBackMessage}];
										   }
										   [AnalyticsManager logEvent:AnalyticsEventWelcomeBackInteraction withAttributes:[attributes copy]];
                                       }
                                    buttonTitle:buttonTitle
                                 buttonCallback:^{
									 NSMutableDictionary *attributes = [NSMutableDictionary new];
									 if (welcomeBackMessage) {
										 [attributes addEntriesFromDictionary:@{@"Notification Message":welcomeBackMessage}];
									 }
									 [AnalyticsManager logEvent:AnalyticsEventReviewedViaButton withAttributes:[attributes copy]];
                                     [self.versioningCoordinator openAppPageInAppStore];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
}

- (NSString *)randomWelcomeBackMessage {
    
    NSArray *welcomeBackMessages = @[NSLocalizedString(@"Enjoy!", @"Welcome Back Message 1"),
                                     NSLocalizedString(@"If you were expecting a signal to do something, this is it. Do it!", @"Welcome Back Message 2"),
                                     NSLocalizedString(@"Do not drink if you're going to drive! #ConsciousDrinking", @"Welcome Back Message 3"),
                                     NSLocalizedString(@"The more people, the better! Call everyone around to join the game!", @"Welcome Back Message 4"),
                                     NSLocalizedString(@"If you like these messages, express yourself in an App Store review! 😇", @"Welcome Back Message 5"),
                                     NSLocalizedString(@"Something missing in the app? Share your thoughts! 😇", @"Welcome Back Message 6"),
                                     NSLocalizedString(@"Did you know the app has cool sound effects around?", @"Welcome Back Message 7"),
                                     NSLocalizedString(@"Because an epic story doesn't start with 'Certain day I was eating a salad and…' ;)", @"Welcome Back Message 8"),
                                     NSLocalizedString(@"Beer, vodka, tequilla, whiskey… It doesn't matter, just enjoy the game!", @"Welcome Back Message 9"),
                                     NSLocalizedString(@"I wonder if anyone even read these texts…", @"Welcome Back Message 10")];
    
    return [welcomeBackMessages objectAtIndex:arc4random() % [welcomeBackMessages count]];
}

#pragma mark - Notification Center -

- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationDeckShuffled object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationNewVersionAvailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationUserDidDeclineAppRating object:nil];
}

- (void)unregisterForNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:SuecaNotificationDeckShuffled]) {
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Deck Shuffled", @"Deck shuffled warning title")
                                           subtitle:NSLocalizedString(@"There're no more cards to be drawn. We shuffled the deck for you.", @"Deck shuffled warning message")
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:NSLocalizedString(@"Got It",nil)
                                     buttonCallback:^{
                                         [[NSUserDefaults standardUserDefaults] setInteger:ShuffleDeckWarningSilence forKey:@"showShuffledDeckWarning"];
										 [[NSUserDefaults standardUserDefaults] synchronize];
										 [AnalyticsManager logEvent:AnalyticsEventOptedOutShuffleWarning withAttributes:notification.userInfo];
                                     }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
    } else if ([notification.name isEqualToString:SuecaNotificationNewVersionAvailable]) {
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Update Available", @"Update available warning title")
                                           subtitle:NSLocalizedString(@"You're using an outdated version of Sueca. Update to have the most awesome new features!", @"Update available warning subtitle")
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:NSLocalizedString(@"Update", @"Update app button")
                                     buttonCallback:^{
										 NSDictionary *attributes = @{@"Notification Title Key":@"Update Available", @"Notification Message Key":@"You're using an outdated version of Sueca. Update to have the most awesome new features!"};
										 [AnalyticsManager logEvent:AnalyticsEventUpdatedViaButton withAttributes:attributes];
										 [self.versioningCoordinator openAppPageInAppStore];
                                     }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
	} else if ([notification.name isEqualToString:SuecaNotificationUserDidDeclineAppRating]) {
#warning to-do: implement and handle mail composing here.
	} else {
        NSLog(@"Unexpected notification: %@",notification);
    }
}

#pragma mark - Customize TSMessage View

- (void)customizeMessageView:(TSMessageView *)messageView {
	if (![messageView.title isEqualToString:NSLocalizedString(@"Deck Shuffled", @"Deck shuffled warning title")] &&
		![messageView.title isEqualToString:NSLocalizedString(@"Update Available", @"Update available warning title")]) {
		
		for (UIView *view in messageView.subviews) {
			if ([view isKindOfClass:[TSBlurView class]]) {
				if (NSClassFromString(@"UIVisualEffectView") != nil) {
					//UIViewVisualEffectView is available, so add it.
					
					UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
					UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:view.frame];
					effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
					effectView.effect = blurEffect;
					[messageView insertSubview:effectView aboveSubview:view];
					[view removeFromSuperview];
				} else { //UIViewVisualEffectView is available, so don't do anything.
					view.alpha = 0.85;
				}
			}
		}
	}
}

@end
