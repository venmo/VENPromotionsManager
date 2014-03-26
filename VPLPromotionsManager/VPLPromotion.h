#import <Foundation/Foundation.h>
#import "VPLLocation.h"

typedef void(^VPLPromotionAction)();

@interface VPLPromotion : NSObject

///The user defaults key that will persist if the promotion has been shown. If this is nil, promotions can trigger more than once on subsequent launches.
@property (nonatomic, strong) NSString *showOnceUserDefaultsKey;

///The event that should occur when a promotion is triggered.Examples include Modal View Controllers and UIAlertviews.
@property (nonatomic, copy) VPLPromotionAction action;

///The first date this promotion can possibly trigger.If startDate is nil, any date prior to the endDate is a valid trigger date.
@property (nonatomic, strong) NSDate *startDate;

///The last date this promotion can possible trigger. If endDate is nil, any date after the startDate is a valid trigger date.
@property (nonatomic, strong) NSDate *endDate;

/**
 Triggers the action block of the promotion.
 */
- (void)triggerPromotion;

/**
 @return YES if the current time is within the valid interval created by startDate and endDate. NO otherwise.
 */
- (BOOL)shouldTriggerOnDate:(NSDate *)date;

/**
 @return YES if the endDate is in the future or is nil, given the current date.
 */
- (BOOL)canTriggerInFutureForCurrentDate:(NSDate *)date;

/**
 This method should not be called. It will be called by super class's of the VPLPromotion during initialization. This method the valid date interval for the promotion, the user defaults key that will persist if the promotion has been shown,and the action that takes place when the promotion is triggered.
 */
- (void)setStartDate:(NSDate *)startDate
             endDate:(NSDate *)endDate
showOnceUserDefaultsKey:(NSString *)userDefaultsKey
              action:(VPLPromotionAction)action;

@end
