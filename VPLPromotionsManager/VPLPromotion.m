#import "VPLPromotion.h"
#import "NSString+VPLSanitiation.h"

@implementation VPLPromotion

#pragma mark - Initialization Methods

- (id) init {
    self = [super init];
    if (self) {
        self.startDate = [NSDate distantPast];
        self.endDate = [NSDate distantFuture];
    }
    return self;
}


#pragma mark - Custom Methods

- (void)triggerPromotion {
    if (self.action) {
        self.action();
    }
}


- (BOOL)shouldTriggerOnDate:(NSDate *)date {
    NSTimeInterval givenDateIntervalSinceReferenceDate = [date timeIntervalSinceReferenceDate];
    NSTimeInterval startDateTimeIntervalSinceReferenceDate = [self.startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endDateTimeIntervalSinceReferenceDate = [self.endDate timeIntervalSinceReferenceDate];
    if (!(startDateTimeIntervalSinceReferenceDate <= givenDateIntervalSinceReferenceDate)) {
        return NO;
    }
    if (!(endDateTimeIntervalSinceReferenceDate >= givenDateIntervalSinceReferenceDate)) {
        return NO;
    }
    return YES;
}

- (BOOL)canTriggerInFutureForCurrentDate:(NSDate *)date {
    NSTimeInterval givenDateIntervalSinceReferenceDate = [date timeIntervalSinceReferenceDate];
    NSTimeInterval endDateTimeIntervalSinceReferenceDate = [self.endDate timeIntervalSinceReferenceDate];
    if (endDateTimeIntervalSinceReferenceDate < givenDateIntervalSinceReferenceDate) {
        return NO;
    }
    return YES;
}

- (NSString *)showOnceUserDefaultsKey {
    if (!self.showOnce) {
        return nil;
    }
    else {
        return [NSString stringWithFormat:@"kVPLOnce%@", self.identifier];
    }
}



@end
