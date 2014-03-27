#import "VPLPromotion.h"
#import <CoreLocation/CoreLocation.h>

@interface VPLBeaconPromotion : VPLPromotion

///The beacon region that should trigger this promotion
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

///The maximum range in which this promotion would be valid.
@property (nonatomic, assign) CLProximity maximumProximity;

///The minimum number of seconds before this promotion can reappear
@property (nonatomic, assign) NSInteger repeatInterval;

///This next date this promotion is triggerable. This should not be set manually. Instead, use startDate.
@property (nonatomic, strong) NSDate* nextFireDate;



/**
 Creates a promotion object instance. If you are creating a singleton object use startWithPromotions: instead.
 @param beaconRegion the beacon region for which this promotion should fire. The region's identifier will also become the promotion's identifier, so it should be unique and must not match the identifier of any other promotion.
 @param maximumProximity the maximum range in which this promotion would be valid
 @param the minimum number of seconds before this promotion can reappear
 @param startDate the first date that the promotion is valid (can be triggered).
 @param endDate startDate the last date that the promotion is valid (can be triggered).
 @param showOnce set to true if this promotion should appear no more than once. If repeatInterval is equal to NSIntegerMax, this will always be true
 @return An `VPLBeaconPromotion` instance
 */
- (instancetype)initWithBeaconRegion:(CLBeaconRegion *)beaconRegion
                withMaximiumProximity:(CLProximity)maximumProximity
                      repeatInterval:(NSInteger)repeatInterval
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                        showOnlyOnce:(BOOL)showOnce
                              action:(VPLPromotionAction)action;

@end