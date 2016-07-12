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
#import "Constants.h"
#import "GameManager.h"
#import "MailComposeViewController.h"
#import "AppearanceHelper.h"
#import "CloudKitManager.h"
#import "NotificationManager.h"
#import "ErrorManager.h"

#import <SafariServices/SafariServices.h>
#import <TSMessages/TSMessageView.h>

@interface TabBarController () <TSMessageViewProtocol, MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate>

@property (strong, nonatomic) GameManager *gameManager;
@property (strong, nonatomic) CloudKitManager *CKManager;
@property (strong, nonatomic) IBOutlet iRateCoordinator *ratingCoordinator;
@property (strong, nonatomic) IBOutlet iVersionCoordinator *versioningCoordinator;

@end

@implementation TabBarController

#pragma mark - Lifecycle -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.gameManager = [GameManager sharedInstance];
	self.CKManager = [CloudKitManager new];
	[self registerForNotification];
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showShuffledDeckWarning"] == ShuffleDeckWarningNeverDecided) {
		[[NSUserDefaults standardUserDefaults] setInteger:ShuffleDeckWarningDisplay forKey:@"showShuffledDeckWarning"];
	}
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstTimeRunning"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTimeRunning"];
		[Deck createDefaultDeck];
	} else {
		[self performSelector:@selector(showWelcomeBackMessage) withObject:nil afterDelay:3.0];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[self unregisterFromNotification];
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
										  image:[UIImage imageNamed:@"suecaLogo"]
										   type:TSMessageNotificationTypeMessage
									   duration:TSMessageNotificationDurationAutomatic
									   callback:^{
										   [TSMessage dismissActiveNotification];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationActiveRemoteNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationActiveLocalNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SuecaNotificationOpenURL object:nil];
}

- (void)unregisterFromNotification {
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
										   callback:^{
											   [TSMessage dismissActiveNotification];
											   [AnalyticsManager logEvent:AnalyticsEventDeckShuffledInteraction];
										   }
										buttonTitle:NSLocalizedString(@"Got It",nil)
									 buttonCallback:^{
										 [[NSUserDefaults standardUserDefaults] setInteger:ShuffleDeckWarningSilence forKey:@"showShuffledDeckWarning"];
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
										   callback:^{
											   [AnalyticsManager logEvent:AnalyticsEventUpdatedViaNotificationInteraction];
											   [self.versioningCoordinator openAppPageInAppStore];
										   }
										buttonTitle:NSLocalizedString(@"Update", @"Update app button")
									 buttonCallback:^{
										 [AnalyticsManager logEvent:AnalyticsEventUpdatedViaButton];
										 [self.versioningCoordinator openAppPageInAppStore];
									 }
										 atPosition:TSMessageNotificationPositionTop
							   canBeDismissedByUser:YES];
		
	} else if ([notification.name isEqualToString:SuecaNotificationUserDidDeclineAppRating]) {
		
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You don't drink?!", nil) message:NSLocalizedString(@"Okay, there's something really strange going on. Would you like to drop us a letter?", nil) preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Contact us", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[self didContactUs];
		}];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No thanks", nil) style:UIAlertActionStyleCancel handler:nil];
		[alert addAction:action];
		[alert addAction:cancelAction];
		[self presentViewController:alert animated:YES completion:nil];
		
	} else if ([notification.name isEqualToString:SuecaNotificationActiveRemoteNotification] ||
			   [notification.name isEqualToString:SuecaNotificationActiveLocalNotification]) {
		__block __weak typeof(self) weakSelf = self;
		[self.CKManager fetchLatestPromotionWithCompletion:^(NSError *error, Promotion *promotion) {
			if (!error) {
				dispatch_async(dispatch_get_main_queue(), ^(void) {
					[TSMessage showNotificationInViewController:weakSelf
														  title:promotion.title
													   subtitle:promotion.shortDescription
														  image:[UIImage imageNamed:@"suecaLogo"]
														   type:TSMessageNotificationTypeMessage
													   duration:TSMessageNotificationDurationEndless
													   callback:^{
														   [AnalyticsManager logEvent:AnalyticsEventPromoNotificationInteraction withAttributes:promotion.attributes];
													   }
													buttonTitle:NSLocalizedString(@"View", nil)
												 buttonCallback:^{
													 [AnalyticsManager logEvent:AnalyticsEventPromoNotificationButton withAttributes:promotion.attributes];
													 [weakSelf setSelectedIndex:1];
												 }
													 atPosition:TSMessageNotificationPositionTop
										   canBeDismissedByUser:YES];
				});
				[self showNotificationIfNeeded];
			} else {
				if ([error.domain isEqualToString:[[NSBundle mainBundle] bundleIdentifier]] && error.code == SuecaErrorNoValidPromotionsFound) {
					[AnalyticsManager logEvent:AnalyticsErrorReceivedPushWithZeroPromo];
				} else {
					dispatch_async(dispatch_get_main_queue(), ^(void) {
						[TSMessage showNotificationInViewController:weakSelf
															  title:NSLocalizedString(@"Promotion Found", nil)
														   subtitle:NSLocalizedString(@"A promotion was detected, but it couldn't be loaded at this moment. Please try again later.", nil)
															  image:nil
															   type:TSMessageNotificationTypeWarning
														   duration:TSMessageNotificationDurationEndless
														   callback:^{
															   [AnalyticsManager logEvent:AnalyticsEventPromoErrorInteraction];
														   }
														buttonTitle:NSLocalizedString(@"View", nil)
													 buttonCallback:^{
														 [AnalyticsManager logEvent:AnalyticsEventPromoErrorButton];
														 [weakSelf setSelectedIndex:1];
													 }
														 atPosition:TSMessageNotificationPositionTop
											   canBeDismissedByUser:YES];
					});
					[AnalyticsManager logEvent:AnalyticsErrorReceivedPushWithUnknownError withAttributes:error.userInfo];
				}
			}
		}];
	} else if ([notification.name isEqualToString:SuecaNotificationOpenURL]){
		NSURL *url = [notification.userInfo objectForKey:@"url"];
		if (url) {
			if ([SFSafariViewController class] != nil) { //Safari View Controller is available
				SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
				safariVC.delegate = self;
				[self presentViewController:safariVC animated:YES completion:nil];
				[AnalyticsManager logEvent:AnalyticsEventOpenURL withAttributes:@{@"SafariVC":@YES, @"url":url.absoluteString}];
			} else { //Safari View Controller is not available
				[[UIApplication sharedApplication] openURL:url];
				[AnalyticsManager logEvent:AnalyticsEventOpenURL withAttributes:@{@"SafariVC":@NO, @"url":url.absoluteString}];
			}
		} else {
			[self presentViewController:[ErrorManager alertFromErrorIdentifier:SuecaErrorInvalidURL] animated:YES completion:nil];
		}
	} else {
		NSLog(@"Unexpected notification: %@", notification);
	}
}

- (void)showNotificationIfNeeded {
	NSInteger pendingNotifications = [NotificationManager pendingNotificationCount];
	if (pendingNotifications > 0) {
		[[self.tabBar.items lastObject] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)pendingNotifications]];
	} else {
		[[self.tabBar.items lastObject] setBadgeValue:nil];
	}
}

#pragma mark - Customize TSMessage View -

- (void)customizeMessageView:(TSMessageView *)messageView {
	[AppearanceHelper customizeMessageView:messageView];
}

#pragma mark - Mail Compose Methods -

- (void)didContactUs {
	if ([MailComposeViewController canSendMail]) {
		[AppearanceHelper defaultBarTintColor];
		[AnalyticsManager logEvent:AnalyticsEventViewMailComposeVC withAttributes:@{@"canDisplayMailCompose":@YES}];
		MailComposeViewController *mailComposeViewController = [MailComposeViewController new];
		mailComposeViewController.mailComposeDelegate = self;
		[self presentViewController:mailComposeViewController animated:YES completion:^{
			[AppearanceHelper customBarTintColor];
		}];
	} else {
		[AnalyticsManager logEvent:AnalyticsEventViewMailComposeVC withAttributes:@{@"canDisplayMailCompose":@NO}];
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Mail Unavailable", nil) message:NSLocalizedString(@"Your device isn't configured to send emails. Please contact us at rogerluan.oba@gmail.com",nil) preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:nil];
		[alert addAction:cancelAction];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

#pragma mark - Mail Compose Delegate Method -

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[AnalyticsManager logEvent:AnalyticseventDidInteractWithMailCompose withAttributes:@{@"result":[NSNumber numberWithInteger:result]}];
	
	__weak typeof(self) weakSelf = self;
	[controller dismissViewControllerAnimated:YES completion:^{
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				[weakSelf presentViewController:[ErrorManager alertFromErrorIdentifier:SuecaErrorFailedToEmail] animated:YES completion:nil];
			});
		}
	}];
}

#pragma mark - Safari View Controller Delegate Method -

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
	[AnalyticsManager logEvent:AnalyticsEventDidLoadURL withAttributes:@{@"didLoadSuccessfully":[NSNumber numberWithBool:didLoadSuccessfully]}];
}

@end
