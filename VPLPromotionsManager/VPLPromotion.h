#import <Foundation/Foundation.h>
#import "VPLLocation.h"

typedef void(^VPLPromotionAction)();

@interface VPLPromotion : NSObject

///The city that the user location should contain if the promotion should be fired. kVPLWildCardLocationAttribute will make all cities valid.
@property (nonatomic, strong) NSString *city;

///The state that the user location should contain if the promotion should be fired. kVPLWildCardLocationAttribute will make all states valid.
@property (nonatomic, strong) NSString *state;

///The country that the user location should contain if the promotion should be fired. kVPLWildCardLocationAttribute will make all countries valid.
@property (nonatomic, strong) NSString *country;

///The center of the valid geocircle in which the promotion can be triggered.
@property (nonatomic, strong) CLLocation *centerLocation;

///The radius distance of the valid geocircle (in meters) in which the promotion can be triggered.
@property (nonatomic, assign) NSUInteger range;

///The user defaults key that will persist if the promotion has been shown. If this is nil, promotions can trigger more than once on subsequent launches.
@property (nonatomic, strong) NSString *showOnceUserDefaultsKey;

///The event that should occur when a promotion is triggered.Examples include Modal View Controllers and UIAlertviews.
@property (nonatomic, copy) VPLPromotionAction action;

///The first date this promotion can possibly trigger.If startDate is nil, any date prior to the endDate is a valid trigger date.
@property (nonatomic, strong) NSDate *startDate;

///The last date this promotion can possible trigger. If endDate is nil, any date after the startDate is a valid trigger date.
@property (nonatomic, strong) NSDate *endDate;



/**
 Initializes the VPLPromotion object with
 @param city the city the promotion should trigger in.
 @param state the state the promotion should trigger in.
 @param country the country the promotion should trigger in.
 @param startDate the first date that the promotion is valid (can be triggered).
 @param endDate startDate the last date that the promotion is valid (can be triggered).
 @return A `VPLPromotion` object
 */
- (instancetype)initWithCity:(NSString *)city
                       state:(NSString *)state
                     country:(NSString *)country
                   startDate:(NSDate *)startDate
                     endDate:(NSDate *)endDate
             showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                      action:(VPLPromotionAction)action;


/**
 Initializes the VPLPromotion object with
 @param center the center of the valid geocircle in which the promotion can be triggered.
 @param range the radius distance (in meters) of the valid geocircle in which the promotion can be triggered.
 @param startDate the first date that the promotion is valid (can be triggered).
 @param endDate startDate the last date that the promotion is valid (can be triggered).
 @return A VPLPromotion object
 */
- (instancetype)initWithCenter:(CLLocation *)centerLocation
                         range:(NSUInteger)range
                     startDate:(NSDate *)startDate
                       endDate:(NSDate *)endDate
               showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                        action:(VPLPromotionAction)action;
/**
 Triggers the action block of the promotion.
 */
- (void)triggerPromotion;

/**
 @return YES if the VPLLocation matches either the promotion's city, state, country or is within the valid geocircle created by the center location and range. NO otherwise.
 */
- (BOOL)shouldTriggerAtLocation:(VPLLocation *)location;


/**
 @return YES if the current time is within the valid interval created by startDate and endDate. NO otherwise.
 */
- (BOOL)shouldTriggerOnDate:(NSDate *)date;


/**
 @return YES if the VPLLocation matches either the promotion's city, state, country or is within the valid geocircle created by the center location and range and if the current time is within the valid interval created by startDate and endDate. NO otherwise.
 */
- (BOOL)shouldTriggerOnDate:(NSDate *)date atLocation:(VPLLocation *)location;

@end
