//
//  Constants.h
//  Sueca
//
//  Created by Roger Luan on 6/30/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define NUMBER_OF_CARDS 13

static NSString * const MainStoryboard = @"Storyboard";
static NSString * const TabBarControllerIdentifier = @"TabBarController";
static NSString * const DecksNavigationControllerIdentifier = @"DecksNavigationController";
static NSString * const GameViewControllerIdentifier = @"GameViewController";
static NSString * const EditDeckTableViewControllerIdentifier = @"EditDeckTableViewController";

#pragma mark - Notification Center
static NSString * const SuecaNotificationUserDidDeclineAppRating = @"UserDidDeclineAppRating";
static NSString * const SuecaNotificationUpdateDeck = @"updateDeck";
static NSString * const SuecaNotificationDeckShuffled = @"deckShuffled";
static NSString * const SuecaNotificationNewVersionAvailable = @"newVersionAvailable";


typedef NS_ENUM(NSUInteger, ShuffleDeckWarning) {
	ShuffleDeckWarningNeverDecided = 0,
	ShuffleDeckWarningDisplay,
	ShuffleDeckWarningSilence
};

#pragma mark - Deprecated Constants -

/*!
 *  BOOL key in NSUserDefaults to determine if should show message with key:
 *  "You can now edit the name of your decks by tapping Edit and selecting the deck. Enjoy!"
 */
//static NSString * const NewFeatureNotification = @"showNewFeatureNotification";

//NSLocalizedString(@"Customizable!", @"TSMessage Customizable Notification Title")
//NSLocalizedString(@"You can now edit the name of your decks by tapping Edit and selecting the deck. Enjoy!", @"TSMessage Customizable Notification Subtitle")

#endif /* Constants_h */
