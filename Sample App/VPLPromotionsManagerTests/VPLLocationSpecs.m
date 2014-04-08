#import "VPLLocation.h"

SpecBegin(VPLLocationSpecs)

describe(@"Initialization", ^{
    
    it(@"should consider an empty object invalid", ^{
        VPLLocation *location = [[VPLLocation alloc] init];
        expect([location isValid]).to.equal(NO);
    });
    
    it(@"should consider an object with a city, state and country valid", ^{
        VPLLocation *location = [[VPLLocation alloc] init];
        location.city       = @"Houston";
        location.state      = @"TX";
        location.country    = @"USA";
        expect([location isValid]).to.equal(YES);
    });
    
    it(@"should consider an object with partial city, state, country data invalid", ^{
        VPLLocation *locationCityOnly = [[VPLLocation alloc] init];
        locationCityOnly.city = @"Houston";
        expect([locationCityOnly isValid]).to.equal(NO);
        
        VPLLocation *locationStateOnly = [[VPLLocation alloc] init];
        locationStateOnly.state = @"Texas";
        expect([locationStateOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCountryOnly = [[VPLLocation alloc] init];
        locationCountryOnly.country = @"USA";
        expect([locationCountryOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCityStateOnly = [[VPLLocation alloc] init];
        locationCityStateOnly.city  = @"Houston";
        locationCityStateOnly.state = @"Texas";
        expect([locationCityStateOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCityCountryOnly = [[VPLLocation alloc] init];
        locationCityCountryOnly.city    = @"Houston";
        locationCityCountryOnly.country = @"USA";
        expect([locationCityCountryOnly isValid]).to.equal(NO);
        
        VPLLocation *locationStateCountryOnly = [[VPLLocation alloc] init];
        locationStateCountryOnly.state      = @"TX";
        locationStateCountryOnly.country    = @"USA";
        expect([locationStateCountryOnly isValid]).to.equal(NO);
    });

    it(@"should consider an object initialized with an invalid dictionary invalid", ^{
        VPLLocation *locationCityOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"city":@"Houston"}];
        expect([locationCityOnly isValid]).to.equal(NO);
        
        VPLLocation *locationStateOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"region":@"TX"}];
        expect([locationStateOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCountryOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"country":@"USA"}];
        expect([locationCountryOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCityStateOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"city":@"Houston",
                                                                                               @"region":@"TX"}];
        expect([locationCityStateOnly isValid]).to.equal(NO);
        
        VPLLocation *locationCityCountryOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"city":@"Houston",
                                                                                                 @"country":@"USA"}];
        expect([locationCityCountryOnly isValid]).to.equal(NO);
        
        VPLLocation *locationStateCountryOnly = [[VPLLocation alloc] initWithLocationDictionary:@{@"region":@"TX",
                                                                                                  @"region":@"Texas"}];
        expect([locationStateCountryOnly isValid]).to.equal(NO);
        
        VPLLocation *invalidDictionaryLocation = [[VPLLocation alloc] initWithLocationDictionary:((NSDictionary *)[NSString stringWithFormat:@"test"])];
        expect([invalidDictionaryLocation isValid]).to.equal(NO);
        
        VPLLocation *nilDictionaryLocation = [[VPLLocation alloc] initWithLocationDictionary:nil];
        expect([nilDictionaryLocation isValid]).to.equal(NO);
    });

    it(@"should consider an object initialized with a valid dictionary valid", ^{
        VPLLocation *location = [[VPLLocation alloc] initWithLocationDictionary:@{@"city":@"Houston",
                                                                                  @"region":@"TX",
                                                                                  @"country":@"USA"}];
        expect([location isValid]).to.equal(YES);
    });
    
});

SpecEnd