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
    
    VPLPromotion *promotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                           state:@"TX"
                                                         country:@"US"
                                                       startDate:beforeDate
                                                         endDate:afterDate
                                         showOnceUserDefaultsKey:nil
                                                          action:^(VPLLocation * location) { }];
    
    
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
    VPLPromotion *promotion = [[VPLPromotion alloc] initWithCity:kVPLWildCardLocationAttribute
                                                           state:@"TX"
                                                         country:@"US"
                                                       startDate:beforeDate
                                                         endDate:afterDate
                                         showOnceUserDefaultsKey:nil
                                                          action:^(VPLLocation * location) { }];
    
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
    VPLPromotion *promotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                           state:kVPLWildCardLocationAttribute
                                                         country:@"US"
                                                       startDate:beforeDate
                                                         endDate:afterDate
                                         showOnceUserDefaultsKey:nil
                                                          action:^(VPLLocation * location) { }];
    
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
    VPLPromotion *promotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                           state:@"TX"
                                                         country:kVPLWildCardLocationAttribute
                                                       startDate:beforeDate
                                                         endDate:afterDate
                                         showOnceUserDefaultsKey:nil
                                                          action:^(VPLLocation * location) { }];
    
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

describe(@"shouldTriggerForLocation", ^{
    VPLPromotion *validTimeIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                            state:@"TX"
                                                                          country:@"US"
                                                                        startDate:beforeDate
                                                                          endDate:afterDate
                                                          showOnceUserDefaultsKey:nil
                                                                           action:^(VPLLocation * location) { }];
    it(@"should trigger for if current time is after start date and before end date", ^{
        expect([validTimeIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(YES);
    });
    
    VPLPromotion *nilStartDateValidEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                           state:@"TX"
                                                                                         country:@"US"
                                                                                       startDate:nil
                                                                                         endDate:afterDate
                                                                         showOnceUserDefaultsKey:nil
                                                                                          action:^(VPLLocation * location) { }];
    it(@"should trigger for nil start date if end date is after current time", ^{
        expect([nilStartDateValidEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(YES);
    });
    
    VPLPromotion *nilStartDateInvalidEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                             state:@"TX"
                                                                                           country:@"US"
                                                                                         startDate:nil
                                                                                           endDate:beforeDate
                                                                           showOnceUserDefaultsKey:nil
                                                                                            action:^(VPLLocation * location) { }];
    it(@"should not trigger for nil start date if end date is before current time", ^{
        expect([nilStartDateInvalidEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(NO);
    });
    
    VPLPromotion *nilStartDateNilEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                         state:@"TX"
                                                                                       country:@"US"
                                                                                     startDate:nil
                                                                                       endDate:nil
                                                                       showOnceUserDefaultsKey:nil
                                                                                        action:^(VPLLocation * location) { }];
    it(@"should always trigger for nil start time and nil end time", ^{
        expect([nilStartDateNilEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(YES);
    });
    
    VPLPromotion *validStartDateNilEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                           state:@"TX"
                                                                                         country:@"US"
                                                                                       startDate:beforeDate
                                                                                         endDate:nil
                                                                         showOnceUserDefaultsKey:nil
                                                                                          action:^(VPLLocation * location) { }];
    it(@"should trigger for start date prior to current date and nil end date", ^{
        expect([validStartDateNilEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(YES);
    });
    
    VPLPromotion *invalidStartDateNilEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                             state:@"TX"
                                                                                           country:@"US"
                                                                                         startDate:afterDate
                                                                                           endDate:nil
                                                                           showOnceUserDefaultsKey:nil
                                                                                            action:^(VPLLocation * location) { }];
    it(@"should not trigger for start date after current date and nil end date", ^{
        expect([invalidStartDateNilEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(NO);
        
    });
    
    VPLPromotion *invalidStartDateAndInvalidEndDateIntervalPromotion = [[VPLPromotion alloc] initWithCity:@"Austin"
                                                                                                    state:@"TX"
                                                                                                  country:@"US"
                                                                                                startDate:afterDate
                                                                                                  endDate:beforeDate
                                                                                  showOnceUserDefaultsKey:nil
                                                                                                   action:^(VPLLocation * location) { }];
    it(@"should not trigger for start date after current date and end date prior to current date", ^{
        expect([invalidStartDateAndInvalidEndDateIntervalPromotion shouldTriggerOnDate:currentDate]).to.equal(NO);
    });
    
});

SpecEnd