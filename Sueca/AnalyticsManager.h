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
static NSString * const AnalyticsEventDidPressReturnKeyFromTextField = @"ReturnKey on UITextField";
static NSString * const AnalyticsEventDidPressReturnKeyFromTextView = @"ReturnKey on UITextView";
static NSString * const AnalyticsEventReviewedViaButton = @"ReviewedViaButton";
static NSString * const AnalyticsEventUpdatedViaButton = @"UpdatedViaButton";
static NSString * const AnalyticsEventPromoNotificationButton = @"PromoNotificationButton";
static NSString * const AnalyticsEventPromoErrorButton = @"PromoErrorButton";
static NSString * const AnalyticsEventShakeCancelButton = @"ShakeCancelButton";
static NSString * const AnalyticsEventShakeAcceptButton = @"ShakeAcceptButton";
static NSString * const AnalyticsEventPushRegistrationButton = @"PushRegistrationButton";
static NSString * const AnalyticsEventEditDecksButton = @"EditDecksButton";
static NSString * const AnalyticsEventCTAButton = @"CTAButton";

#pragma mark - General Events
static NSString * const AnalyticsEventOpenURL = @"OpenURL";
static NSString * const AnalyticsEventDidLoadURL = @"DidLoadURL";
static NSString * const AnalyticsEventDidReceivePushInBackground = @"DidReceivePushInBackground";
static NSString * const AnalyticsEventDidUpdatePromotionView = @"DidUpdatePromotionView";
static NSString * const AnalyticsEventDidRegisterLocalNotification = @"DidRegisterLocalNotification";
static NSString * const AnalyticsEventDidShareCard = @"DidShareCard";
static NSString * const AnalyticsEventTrackGlobalSortCount = @"GlobalSortCount";
static NSString * const AnalyticsEventSuccessfullyRegisteredSubscription = @"SuccessfullyRegisteredSubscription";
static NSString * const AnalyticsEventShouldDisplayPromoCard = @"ShouldDisplayPromoCard";

#pragma mark - iRate
static NSString * const AnalyticsEventiRateUserDidAttemptToRateApp = @"iRate UserDidAttemptToRateApp";
static NSString * const AnalyticsEventiRateUserDidDeclineToRateApp = @"iRate UserDidDeclineToRateApp";
static NSString * const AnalyticsEventiRateUserDidRequestReminderToRateApp = @"iRate UserDidRequestReminderToRateApp";
static NSString * const AnalyticsEventiRateDidOpenAppStore = @"iRate DidOpenAppStore";

#pragma mark - User Info
static NSString * const AnalyticsEventOptedOutShuffleWarning = @"OptedOutShuffleWarning";
static NSString * const AnalyticsEventCKAccountStatus = @"CKAccountStatus";

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
static NSString * const AnalyticsEventViewMailComposeVC = @"ViewMailComposeVC";
static NSString * const AnalyticsEventViewPromoCard = @"ViewPromoCard";

static NSString * const AnalyticsEventDeckCreationView = @"DeckCreationView";
static NSString * const AnalyticsEventDeckEditView = @"DeckEditView";
static NSString * const AnalyticsEventCardDescriptionView = @"CardDescriptionView";
static NSString * const AnalyticsEventShareActivityView = @"ShareActivityView";
static NSString * const AnalyticsEventErrorAlertView = @"ErrorAlertView";
static NSString * const AnalyticsEventNotificationPermissionView = @"NotificationPermissionView";

#pragma mark - Error
static NSString * const AnalyticsErrorReceivedPushWithZeroPromo = @"ReceivedPushWithZeroPromo";
static NSString * const AnalyticsErrorReceivedPushWithUnknownError = @"ReceivedPushWithUnknownError";
static NSString * const AnalyticsErrorFailedClearBadges = @"FailedClearBadges";
static NSString * const AnalyticsErrorFailedLoadingPromotionsSilently = @"FailedLoadingPromotionsSilently";
static NSString * const AnalyticsErrorHandleRemoteNotificationError = @"HandleRemoteNotificationError";
static NSString * const AnalyticsErrorFailedSubscriptionRegistration = @"FailedSubscriptionRegistration";

@interface AnalyticsManager : NSObject

+ (void)trackGlobalSortCount;
+ (void)increaseGlobalSortCount;
+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withAttributes:(NSDictionary *)attributes;
+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType;
+ (void)logContentViewEvent:(NSString *)eventName contentType:(NSString *)contentType customAttributes:(NSDictionary *)attributes;
@end
