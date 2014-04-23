#import "VPLLocationPromotion.h"

VPLLocation *emptyLocation;
VPLLocation *validLocation;
VPLLocation *validLocationUnsanitized;
VPLLocation *validWrongCityLocation;
VPLLocation *validWrongStateLocation;
VPLLocation *validWrongCountryLocation;
NSDate *currentDate;
NSDate *beforeDate;
NSDate *afterDate;

SpecBegin(VPLLocationPromotionSpecs)

currentDate = [NSDate date];
beforeDate = [currentDate dateByAddingTimeInterval:-1*60*60];
afterDate = [currentDate dateByAddingTimeInterval:60*60];

before(^{
    emptyLocation = [[VPLLocation alloc] init];
    
    validLocation = [[VPLLocation alloc] init];
    validLocation.city    = @"Austin";
    validLocation.state   = @"TX";
    validLocation.country = @"US";
    
    validLocationUnsanitized = [[VPLLocation alloc] init];
    validLocationUnsanitized.city     = @"AUS Ti' n";
    validLocationUnsanitized.state    = @"T X?}*";
    validLocationUnsanitized.country  = @"U]S''' |||]]";
    
    validWrongCityLocation = [[VPLLocation alloc] init];
    validWrongCityLocation.city    = @"Houston";
    validWrongCityLocation.state   = @"TX";
    validWrongCityLocation.country = @"US";
    
    validWrongStateLocation = [[VPLLocation alloc] init];
    validWrongStateLocation.city    = @"Austin";
    validWrongStateLocation.state   = @"NY";
    validWrongStateLocation.country = @"US";
    
    validWrongCountryLocation = [[VPLLocation alloc] init];
    validWrongCountryLocation.city    = @"Austin";
    validWrongCountryLocation.state   = @"TX";
    validWrongCountryLocation.country = @"MX";
    
});

describe(@"Non wildcard promotion shouldTriggerForLocation", ^{
    
    VPLLocationPromotion *promotion = [[VPLLocationPromotion alloc] initWithCity:@"Austin" state:@"TX" country:@"US" uniqueIdentifier:@"uniqueID" action:^{
    }];
    promotion.startDate = beforeDate;
    promotion.endDate   = afterDate;
    
    it(@"should never trigger for empty object", ^{
        expect([promotion shouldTriggerAtLocation:emptyLocation]).to.equal(NO);
    });
    
    it(@"should never trigger for a different city", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCityLocation]).to.equal(NO);
    });
    
    it(@"should trigger for the correct location", ^{
        expect([promotion shouldTriggerAtLocation:validLocation]).to.equal(YES);
    });
});

describe(@"City wildcard promotion shouldTriggerForLocation", ^{

    VPLLocationPromotion *promotion = [[VPLLocationPromotion alloc] initWithCity:kVPLWildCardLocationAttribute
                                                                           state:@"TX"
                                                                         country:@"US"
                                                            uniqueIdentifier:@"uniqueID" action:^{
    }];
    promotion.startDate = beforeDate;
    promotion.endDate   = afterDate;
    
    it(@"should never trigger for empty object", ^{
        expect([promotion shouldTriggerAtLocation:emptyLocation]).to.equal(NO);
    });
    
    it(@"should trigger for a different city", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCityLocation]).to.equal(YES);
    });
    
    it(@"should not trigger for a different state", ^{
        expect([promotion shouldTriggerAtLocation:validWrongStateLocation]).to.equal(NO);
    });
    
    it(@"should not trigger for a different country", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCountryLocation]).to.equal(NO);
    });
});

describe(@"State wildcard promotion shouldTriggerForLocation", ^{
    
    VPLLocationPromotion *promotion = [[VPLLocationPromotion alloc] initWithCity:@"Austin"
                                                                           state:kVPLWildCardLocationAttribute
                                                                         country:@"US"
                                                                uniqueIdentifier:@"uniqueID" action:^{
                                                                }];
    promotion.startDate = beforeDate;
    promotion.endDate   = afterDate;
    it(@"should never trigger for empty object", ^{
        expect([promotion shouldTriggerAtLocation:emptyLocation]).to.equal(NO);
    });
    
    it(@"should not trigger for a different city", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCityLocation]).to.equal(NO);
    });
    
    it(@"should trigger for a different state", ^{
        expect([promotion shouldTriggerAtLocation:validWrongStateLocation]).to.equal(YES);
    });
    
    it(@"should not trigger for a different country", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCountryLocation]).to.equal(NO);
    });
});

describe(@"Country wildcard promotion shouldTriggerForLocation", ^{
    VPLLocationPromotion *promotion = [[VPLLocationPromotion alloc] initWithCity:@"Austin"
                                                                           state:@"TX"
                                                                         country:kVPLWildCardLocationAttribute
                                                                uniqueIdentifier:@"uniqueID" action:^{
                                                                }];
    promotion.startDate = beforeDate;
    promotion.endDate   = afterDate;
    
    it(@"should never trigger for empty object", ^{
        expect([promotion shouldTriggerAtLocation:emptyLocation]).to.equal(NO);
    });
    
    it(@"should not trigger for a different city", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCityLocation]).to.equal(NO);
    });
    
    it(@"should not trigger for a different state", ^{
        expect([promotion shouldTriggerAtLocation:validWrongStateLocation]).to.equal(NO);
    });
    
    it(@"should trigger for a different country", ^{
        expect([promotion shouldTriggerAtLocation:validWrongCountryLocation]).to.equal(YES);
    });
});


SpecEnd