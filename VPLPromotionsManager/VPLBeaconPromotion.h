#import "VPLPromotion.h"
#import <CoreLocation/CoreLocation.h>

@interface VPLBeaconPromotion : VPLPromotion

@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

- (instancetype)initWithBeaconRegion:(CLBeaconRegion *)beaconRegion
                            startDate:(NSDate *)startDate
                              endDate:(NSDate *)endDate
              showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                               action:(VPLPromotionAction)action;

@end
