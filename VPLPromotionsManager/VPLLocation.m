#import "VPLLocation.h"

@implementation VPLLocation

- (instancetype)initWithLocationDictionary:(NSDictionary *)userLocation {
    self = [super init];
    if (self) {
        if ([userLocation isKindOfClass:[NSDictionary class]]) {
            self.city       = userLocation[@"city"];
            self.state      = userLocation[@"region"];
            self.country    = userLocation[@"country"];
        }
    }
    return self;
}


- (instancetype)initWithLocation:(CLLocation *)location {
    if (self) {
        self.absoluteLocation = location;
    }
    return self;
}


- (BOOL)isValid {
    if (self.city && self.state && self.country) {
        return YES;
    }
    if (self.absoluteLocation) {
        return YES;
    }
    return NO;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"VPLLocation City:%@ State:%@ Country:%@ CLLocation: %@",self.city, self.state, self.country, self.absoluteLocation];
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
