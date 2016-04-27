//
//  TabBarController.m
//  Sueca
//
//  Created by Roger Luan on 4/25/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import "TabBarController.h"
#import "TSMessage.h"
#import "TSMessageView.h"
#import "GameManager.h"
#import "iVersion.h"
#import "iRate.h"
#import <Parse/Parse.h>

@interface TabBarController ()<TSMessageViewProtocol,iVersionDelegate,iRateDelegate>

@property (strong, nonatomic) GameManager *gameManager;

@end

@implementation TabBarController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gameManager = [GameManager new];
    [self registerForNotification];
    
    /* Creates default deck only once */
    
    //0: never decided
    //1: displays warning
    //2: opted out
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showShuffledDeckWarning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showNoDescriptionWarning"] == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"showNoDescriptionWarning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Deck createDefaultDeck];
    } else {
        [self performSelector:@selector(showWelcomeBackMessage) withObject:nil afterDelay:3.0];
    }
    
    [[iVersion sharedInstance] checkForNewVersion];
    [[iVersion sharedInstance] setDelegate:self];
    [[iRate sharedInstance] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
                                           [PFAnalytics trackEventInBackground:@"interactionWithWelcomeBack" dimensions:nil block:^(BOOL succeeded, NSError *error) {
                                               if (!error) {
                                                   NSLog(@"Successfully logged the 'interactionWithWelcomeBack' event");
                                               }
                                           }];
                                       }
                                    buttonTitle:buttonTitle
                                 buttonCallback:^{
                                     [PFAnalytics trackEventInBackground:@"updatedViaWelcomeBackButton" dimensions:nil block:^(BOOL succeeded, NSError *error) {
                                         if (!error) {
                                             NSLog(@"Successfully logged the 'updatedViaWelcomeBackButton' event");
                                         }
                                     }];
                                     
                                     [[iVersion sharedInstance] openAppPageInAppStore];
                                 }
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
}

/**
 *  @author Roger Oba
 *
 *  Randomizes a Welcome Back message.
 *
 *  @return returns the string of the message
 */
- (NSString*)randomWelcomeBackMessage {
    
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

#pragma mark - iVersion Delegate Methods -

- (void)iVersionDidDetectNewVersion:(NSString *)version details:(NSString *)versionDetails {
    NSLog(@"New version detected!");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newVersionAvailable" object:nil];
}

- (void)iVersionDidNotDetectNewVersion {
    NSLog(@"No new version. Your app is up to date.");
}

#pragma mark - iRate Delegate Methods -

- (void)iRateUserDidAttemptToRateApp {
    [PFAnalytics trackEventInBackground:@"iRateUserDidAttemptToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully logged the 'iRateUserDidAttemptToRateApp' event");
        }
    }];
}

- (void)iRateUserDidDeclineToRateApp {
    [PFAnalytics trackEventInBackground:@"iRateUserDidDeclineToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully logged the 'iRateUserDidDeclineToRateApp' event");
        }
    }];
}

- (void)iRateUserDidRequestReminderToRateApp {
    [PFAnalytics trackEventInBackground:@"iRateUserDidRequestReminderToRateApp" dimensions:nil block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully logged the 'iRateUserDidRequestReminderToRateApp' event");
        }
    }];
}

- (void)iRateDidOpenAppStore {
    [PFAnalytics trackEventInBackground:@"iRateDidOpenAppStore" dimensions:nil block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully logged the 'iRateDidOpenAppStore' event");
        }
    }];
}

#pragma mark - Notification Center -

- (void)registerForNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"deckShuffled" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"newVersionAvailable" object:nil];
}

- (void)unregisterForNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"deckShuffled"]) {
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Deck Shuffled", @"Deck shuffled warning title")
                                           subtitle:NSLocalizedString(@"There're no more cards to be drawn. We shuffled the deck for you.", @"Deck shuffled warning message")
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:NSLocalizedString(@"Got It",nil)
                                     buttonCallback:^{
                                         [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"showShuffledDeckWarning"];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                         NSInteger warningCount = [[notification.userInfo objectForKey:@"warningCount"] intValue];
                                         [PFAnalytics trackEventInBackground:@"showShuffledDeckWarning" dimensions:@{ @"warningCount": [NSString stringWithFormat:@"%ld",(long)warningCount]} block:^(BOOL succeeded, NSError *error) {
                                             if (!error) {
                                                 NSLog(@"Successfully logged the 'showShuffledDeckWarning' event");
                                             }
                                         }];
                                     }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
    } else if ([notification.name isEqualToString:@"newVersionAvailable"]) {
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"Update Available", @"Update available warning title")
                                           subtitle:NSLocalizedString(@"You're using an outdated version of Sueca. Update to have the most awesome new features!", @"Update available warning subtitle")
                                              image:nil
                                               type:TSMessageNotificationTypeWarning
                                           duration:TSMessageNotificationDurationEndless
                                           callback:nil
                                        buttonTitle:NSLocalizedString(@"Update", @"Update app button")
                                     buttonCallback:^{
                                         [PFAnalytics trackEventInBackground:@"updatedViaNotificationButton" dimensions:nil block:^(BOOL succeeded, NSError *error) {
                                             if (!error) {
                                                 NSLog(@"Successfully logged the 'updatedViaNotificationButton' event");
                                             }
                                         }];
                                         
                                         [[iVersion sharedInstance] openAppPageInAppStore];
                                     }
                                         atPosition:TSMessageNotificationPositionTop
                               canBeDismissedByUser:YES];
    } else {
        NSLog(@"Unexpected notification: %@",notification);
    }
}

#pragma mark - Customize TSMessage View
/*
 *  Future Implementation
 *
 *
 
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
*/

@end