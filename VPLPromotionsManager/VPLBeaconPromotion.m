#import "VPLBeaconPromotion.h"

@implementation VPLBeaconPromotion

- (instancetype)initWithBeaconRegion:(CLBeaconRegion *)beaconRegion
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
             showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                              action:(VPLPromotionAction)action {
    self = [super init];
    if (self) {
        self.beaconRegion = beaconRegion;
        [self setStartDate:startDate endDate:endDate showOnceUserDefaultsKey:userDefaultsKey action:action];
    }
    return self;
}


@end
