#import "VPLPromotion.h"
#import <CoreLocation/CoreLocation.h>

@interface VPLBeaconPromotion : VPLPromotion

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, assign) CLProximity maximumProximity;

@property (nonatomic, assign) NSInteger repeatInterval;

@property (nonatomic, strong) NSDate* nextFireDate;


- (instancetype)initWithBeaconRegion:(CLBeaconRegion *)beaconRegion
                withMaximiumProximity:(CLProximity)proximity
                      repeatInterval:(NSInteger)repeatInterval
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
                        showOnlyOnce:(BOOL)showOnce
                              action:(VPLPromotionAction)action;

@end