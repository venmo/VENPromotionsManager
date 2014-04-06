#import "VPLPromotion.h"

@interface VPLLocationPromotion : VPLPromotion

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


/**
 Initializes the VPLPromotion object with
 @param city the city the promotion should trigger in.
 @param state the state the promotion should trigger in.
 @param country the country the promotion should trigger in.
 @param identifier the unique identifier for this promotion.  This must not be nil and must be unique for each promotion.
 @param action the event that should occur when a promotion is triggered.
 @return A `VPLPromotion` object
 */
- (instancetype)initWithCity:(NSString *)city
                       state:(NSString *)state
                     country:(NSString *)country
            uniqueIdentifier:(NSString *)identifier
                      action:(VPLPromotionAction)action;


/**
 Initializes the VPLPromotion object with
 @param center the center of the valid geocircle in which the promotion can be triggered.
 @param range the radius distance (in meters) of the valid geocircle in which the promotion can be triggered.
 @param identifier the unique identifier for this promotion.  This must not be nil and must be unique for each promotion.
 @param action the event that should occur when a promotion is triggered.
 @return A VPLPromotion object
 */
- (instancetype)initWithCenter:(CLLocation *)centerLocation
                         range:(NSUInteger)range
              uniqueIdentifier:(NSString *)identifier
                        action:(VPLPromotionAction)action;


/**
 @return YES if the VPLLocation matches either the promotion's city, state, country or is within the valid geocircle created by the center location and range. NO otherwise.
 */
- (BOOL)shouldTriggerAtLocation:(VPLLocation *)location;


/**
 @return YES if the VPLLocation matches either the promotion's city, state, country or is within the valid geocircle created by the center location and range and if the current time is within the valid interval created by startDate and endDate. NO otherwise.
 */
- (BOOL)shouldTriggerOnDate:(NSDate *)date atLocation:(VPLLocation *)location;


@end
