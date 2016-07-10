//
//  AnalyticsManager.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>

#pragma mark - Interactions & Gestures
static NSString * const AnalyticsEventWelcomeBackInteraction = @"WelcomeBackInteraction";
static NSString * const AnalyticsEventDeckShuffledInteraction = @"DeckShuffledInteraction";
static NSString * const AnalyticsEventUpdatedViaNotificationInteraction = @"UpdatedViaNotificationInteraction";
static NSString * const AnalyticsEventPromoNotificationInteraction = @"PromoNotificationInteraction";
static NSString * const AnalyticsEventPromoErrorInteraction = @"PromoErrorInteraction";

static NSString * const AnalyticsEventTapCardGesture = @"TapCardGesture";
static NSString * const AnalyticsEventTapCardDuringTimer = @"TapCardDuringTimer";
static NSString * const AnalyticsEventDidSwipeCard = @"DidSwipeCard";
static NSString * const AnalyticsEventDidShakeDevice = @"DidShakeDevice";
static NSString * const AnalyticseventDidInteractWithMailCompose = @"DidInteractWithMailCompose";

#pragma mark - Buttons
static NSString * const AnalyticsEventReviewedViaButton = @"ReviewedViaButton";
static NSString * const AnalyticsEventUpdatedViaButton = @"UpdatedViaButton";
static NSString * const AnalyticsEventPromoNotificationButton = @"PromoNotificationButton";
static NSString * const AnalyticsEventPromoErrorButton = @"PromoErrorButton";
static NSString * const AnalyticsEventShakeCancelButton = @"ShakeCancelButton";
static NSString * const AnalyticsEventShakeAcceptButton = @"ShakeAcceptButton";
static NSString * const AnalyticsEventPushRegistrationButton = @"PushRegistrationButton";

#pragma mark - iRate
static NSString * const AnalyticsEventiRateUserDidAttemptToRateApp = @"iRate UserDidAttemptToRateApp";
static NSString * const AnalyticsEventiRateUserDidDeclineToRateApp = @"iRate UserDidDeclineToRateApp";
static NSString * const AnalyticsEventiRateUserDidRequestReminderToRateApp = @"iRate UserDidRequestReminderToRateApp";
static NSString * const AnalyticsEventiRateDidOpenAppStore = @"iRate DidOpenAppStore";

#pragma mark - Opt Out
static NSString * const AnalyticsEventOptedOutShuffleWarning = @"OptedOutShuffleWarning";

#pragma mark - Card Rule Cell
static NSString * const AnalyticsEventDidPressReturnKeyFromTextField = @"ReturnKey on UITextField";
static NSString * const AnalyticsEventDidPressReturnKeyFromTextView = @"ReturnKey on UITextView";

#pragma mark - Card Manipulation
static NSString * const AnalyticsEventDidDeleteCard = @"Deleted Card";
static NSString * const AnalyticsEventDidEditCardRule = @"Edited Card Rule";
static NSString * const AnalyticsEventDidEditCardDescription = @"Edited Card Description";

#pragma mark - Deck Manipulation
static NSString * const AnalyticsEventDidCreateDeck = @"Created Deck";
static NSString * const AnalyticsEventDidDeleteDeck = @"Deleted Deck";
static NSString * const AnalyticsEventDidRenameDeck = @"Renamed Deck";
static NSString * const AnalyticsEventDidSelectDeck = @"Selected Deck";

#pragma mark - Content View
static NSString * const AnalyticsEventViewGameVC = @"ViewGameVC";
static NSString * const AnalyticsEventViewDecksVC = @"ViewDecksVC";
static NSString * const AnalyticsEventViewEditDeckVC = @"ViewEditDeckVC";
static NSString * const AnalyticsEventMailComposeVC = @"MailComposeVC";

static NSString * const AnalyticsEventDeckCreationView = @"DeckCreationView";
static NSString * const AnalyticsEventDeckEditView = @"DeckEditView";
static NSString * const AnalyticsEventCardDescriptionView = @"CardDescriptionView";

static NSString * const AnalyticsEventShareActivityView = @"ShareActivityView";
static NSString * const AnalyticsEventErrorAlert = @"ErrorAlert";

static NSString * const AnalyticsEventOpenURL = @"OpenURL";
static NSString * const AnalyticsEventDidLoadURL = @"DidLoadURL";

static NSString * const AnalyticsEventViewPromoCard = @"ViewPromoCard";

#pragma mark - Share
static NSString * const AnalyticsEventDidShareCard = @"DidShareCard";

#pragma mark - Error
static NSString * const AnalyticsErrorReceivedPushWithZeroPromo = @"ReceivedPushWithZeroPromo";
static NSString * const AnalyticsErrorReceivedPushWithUnknownError = @"ReceivedPushWithUnknownError";
static NSString * const AnalyticsErrorFailedClearBadges = @"FailedClearBadges";

#pragma mark - User Info
static NSString * const AnalyticsEventCKAccountStatus = @"CKAccountStatus";

@interface AnalyticsManager : NSObject

+ (void)trackGlobalSortCount;
+ (void)increaseGlobalSortCount;
+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withAttributes:(NSDictionary *)attributes;
+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType;
+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType customAttributes:(NSDictionary *)attributes;
@end
