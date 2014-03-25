#import "VPLLocationPromotion.h"

@implementation VPLLocationPromotion
- (instancetype)initWithCity:(NSString *)city
                       state:(NSString *)state
                     country:(NSString *)country
                   startDate:startDate
                     endDate:endDate
     showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                      action:(VPLPromotionAction)action {
    self = [super init];
    if (self) {
        self.city       = city;
        self.state      = state;
        self.country    = country;
        [self setStartDate:startDate endDate:endDate showOnceUserDefaultsKey:userDefaultsKey action:action];
    }
    return self;
}


- (instancetype)initWithCenter:(CLLocation *)centerLocation
                         range:(NSUInteger)range
                     startDate:startDate
                       endDate:endDate
       showOnceUserDefaultsKey:(NSString *)userDefaultsKey
                        action:(VPLPromotionAction)action {
    self = [super init];
    if (self) {
        self.centerLocation = centerLocation;
        self.range  = range;
        [self setStartDate:startDate endDate:endDate showOnceUserDefaultsKey:userDefaultsKey action:action];
    }
    return self;
}

- (BOOL)shouldTriggerOnDate:(NSDate *)date atLocation:(VPLLocation *)location {
    if (![location isValid]) {
        return NO;
    }
    if (![self shouldTriggerOnDate:date] || ![self shouldTriggerAtLocation:location]) {
        return NO;
    }
    return YES;
}


- (BOOL)shouldTriggerAtLocation:(VPLLocation *)location {
    if (self.city && self.state && self.country) {
        if (![self.city isEqualToString: location.city] && ![self.city isEqualToString:kVPLWildCardLocationAttribute]) {
            return NO;
        }
        else if (![self.state isEqualToString: location.state] && ![self.state isEqualToString:kVPLWildCardLocationAttribute]) {
            return NO;
        }
        else if (![self.country isEqualToString: location.country] && ![self.country isEqualToString:kVPLWildCardLocationAttribute]) {
            return NO;
        }
        return YES;
    }
    else if (location.absoluteLocation && self.centerLocation) {
        CLLocationDistance distance = ABS([self.centerLocation distanceFromLocation:location.absoluteLocation]);
        if (distance < self.range) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Setters

- (void)setCity:(NSString *)city {
    _city = ![city isKindOfClass:[NSNull class]] ? [city sanitizeString] : @"";
}


- (void)setState:(NSString *)state {
    _state = ![state isKindOfClass:[NSNull class]] ? [state sanitizeString] : @"";
}


- (void)setCountry:(NSString *)country {
    _country = ![country isKindOfClass:[NSNull class]] ? [country sanitizeString] : @"";
}

@end
