#import "VPLPromotion.h"

VPLLocation *emptyLocation;
VPLLocation *validLocation;
VPLLocation *validLocationUnsanitized;
VPLLocation *validWrongCityLocation;
VPLLocation *validWrongStateLocation;
VPLLocation *validWrongCountryLocation;
NSDate *currentDate;
NSDate *beforeDate;
NSDate *afterDate;

SpecBegin(VPLPromotionSpecs)

currentDate = [NSDate date];
beforeDate = [currentDate dateByAddingTimeInterval:-1*60*60];
afterDate = [currentDate dateByAddingTimeInterval:60*60];

describe(@"shouldTriggerForLocation:", ^{
    
    VPLPromotion *promotion = [[VPLPromotion alloc] init];
    
    it(@"should trigger for if current time is after start date and before end date", ^{
        promotion.startDate = beforeDate;
        promotion.endDate   = afterDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });
    
    it(@"should trigger for nil start date if end date is after current time", ^{
        promotion.startDate = nil;
        promotion.endDate = afterDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });
    
    it(@"should not trigger for nil start date if end date is before current time", ^{
        promotion.startDate = nil;
        promotion.endDate = beforeDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beFalsy();
    });
    
    it(@"should always trigger for nil start time and nil end time", ^{
        promotion.startDate = nil;
        promotion.endDate = nil;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });

    it(@"should trigger for start date prior to current date and nil end date", ^{
        promotion.startDate = nil;
        promotion.endDate = nil;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });
    
    it(@"should not trigger for start date after current date and nil end date", ^{
        promotion.startDate = afterDate;
        promotion.endDate = nil;
        expect([promotion shouldTriggerOnDate:currentDate]).beFalsy();
        
    });
    
    it(@"should not trigger for start date after current date and end date prior to current date", ^{
        promotion.startDate = afterDate;
        promotion.endDate = beforeDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beFalsy();
    });
    
});


describe(@"canTriggerInFutureForCurrentDate:", ^{
    VPLPromotion *promotion = [[VPLPromotion alloc] init];
    
    it(@"should trigger for end date after current date", ^{
        promotion.endDate = afterDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });
    
    
    it(@"should not trigger for end date prior to current date", ^{
        promotion.endDate = beforeDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beFalsy();
    });
    
    it(@"should always trigger for end date that is nil", ^{
        promotion.endDate = afterDate;
        expect([promotion shouldTriggerOnDate:currentDate]).beTruthy();
    });

});


describe(@"showOnceUserDefaultsKey:", ^{
    VPLPromotion *promotion = [[VPLPromotion alloc] init];
    
    it(@"should be created from its unique identifier if showOnce is YES", ^{
        promotion.identifier    = @"TestID";
        promotion.showOnce      = YES;
        expect([promotion showOnceUserDefaultsKey]).to.equal(@"kVPLOnceTestID");
    });
    
    it(@"should be nil if showOnce is NO", ^{
        promotion.identifier    = @"TestID";
        promotion.showOnce      = NO;
        expect([promotion showOnceUserDefaultsKey]).to.beNil();
    });
    
});

SpecEnd