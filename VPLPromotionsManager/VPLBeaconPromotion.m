#import "VPLBeaconPromotion.h"

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
        self.nextFireDate = [[NSUserDefaults standardUserDefaults] objectForKey:[self nextFireDateDefaultsKey]];
        if ([[NSDate date] compare: startDate] ==  NSOrderedAscending && !self.nextFireDate) {
            self.nextFireDate = startDate;
            [self saveNextFireDate];
            
        }
        [self setStartDate:startDate
                   endDate:endDate
   showOnceUserDefaultsKey:userDefaultsKey
                    action:action];
    }
    return self;
}

- (NSString *)nextFireDateDefaultsKey {
    return [NSString stringWithFormat:@"kVPL%@NextFireDate", self.beaconRegion.identifier];
}


- (BOOL)shouldTriggerOnDate:(NSDate *)date {
    if (![super shouldTriggerOnDate:date]) {
        return NO;
    }
    if (self.nextFireDate) {
        if ([date compare:self.nextFireDate] == NSOrderedAscending) {
            return NO;
        }
    }
    return YES;
}

- (void)triggerPromotion {
    [super triggerPromotion];
    self.nextFireDate = [[NSDate date] dateByAddingTimeInterval:self.repeatInterval];
    [self saveNextFireDate];
}

- (void) saveNextFireDate {
    [[NSUserDefaults standardUserDefaults] setObject:self.nextFireDate forKey:[self nextFireDateDefaultsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
