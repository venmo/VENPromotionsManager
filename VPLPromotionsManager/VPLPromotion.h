#import <Foundation/Foundation.h>
#import "VPLLocation.h"

typedef void(^VPLPromotionAction)();

@interface VPLPromotion : NSObject

@property (nonatomic, assign) BOOL showOnce;

///A unique identifier for this promotion.  This must not be nil and must be unique for each promotion.
@property (nonatomic, strong) NSString *identifier;

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
 The user defaults key of this promotion.
 */
- (NSString *)showOnceUserDefaultsKey;

@end
