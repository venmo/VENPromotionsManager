#import "VPLBeaconPromotion.h"

@interface VPLBeaconPromotion ()

@property (nonatomic, strong) NSDate* lastFireDate;

@end

@implementation VPLBeaconPromotion

- (instancetype)initWithBeaconRegion:(CLBeaconRegion *)beaconRegion
                           withMaximiumProximity:(CLProximity)proximity
                      repeatInterval:(NSInteger)repeatInterval
                           startDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
             showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                              action:(VPLPromotionAction)action {
    self = [super init];
    if (self) {
        self.beaconRegion       = beaconRegion;
        self.maximumProximity   = proximity;
        self.repeatInterval = repeatInterval;
        self.lastFireDate = [[NSUserDefaults standardUserDefaults] objectForKey:[self lastFireDateDefaultsKey]];
        [self setStartDate:startDate
                   endDate:endDate
   showOnceUserDefaultsKey:userDefaultsKey
                    action:action];
    }
    return self;
}

- (NSString *)lastFireDateDefaultsKey {
    return [NSString stringWithFormat:@"kVPL%@LastFireDate", self.beaconRegion.identifier];
}


- (BOOL)shouldTriggerOnDate:(NSDate *)date {
    if (![super shouldTriggerOnDate:date]) {
        return NO;
    }
    if (self.lastFireDate) {
        NSDate *validAfterDate = [self.lastFireDate dateByAddingTimeInterval:self.repeatInterval];
        if ([date compare:validAfterDate] == NSOrderedAscending) {
            return NO;
        }
    }
    
    return YES;
}

- (void)triggerPromotion {
    [super triggerPromotion];
    self.lastFireDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastFireDate forKey:[self lastFireDateDefaultsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
