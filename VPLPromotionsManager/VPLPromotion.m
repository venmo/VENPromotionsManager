#import "VPLPromotion.h"
#import "NSString+VPLSanitiation.h"

@implementation VPLPromotion

#pragma mark - Initialization Methods


- (void)setStartDate:(NSDate *)startDate
              endDate:(NSDate *)endDate
showOnceUserDefaultsKey:(NSString *)userDefaultsKey
               action:(VPLPromotionAction)action {
    self.startDate = startDate ? startDate : [NSDate distantPast];
    self.endDate = endDate ? endDate : [NSDate distantFuture];
    self.showOnceUserDefaultsKey = userDefaultsKey;
    self.action = action;
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



@end
