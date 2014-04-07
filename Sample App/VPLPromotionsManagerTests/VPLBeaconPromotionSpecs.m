#import "VPLRegionPromotion.h"

NSString *VPL_TEST_UUID = @"DF47BE82-B64C-4545-9D1A-2FA7486725FF";

SpecBegin(VPLBeaconPromotion)

describe(@"Initialization", ^{

    it(@"should set showOnce to true by default when setting repeatInterval to NSIntegerMax", ^{
        NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:VPL_TEST_UUID];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:testUUID identifier:@"TestID"];
        VPLRegionPromotion *promotion = [[VPLRegionPromotion alloc] initWithRegion:region
                                                                          repeatInterval:NSIntegerMax
                                                                            enterAction:^{
                                                                            }];
        expect(promotion.showOnce).beTruthy();
    });
    
    it(@"should set showOnce to true by default when setting repeatInterval to any other number", ^{
        NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:VPL_TEST_UUID];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:testUUID identifier:@"TestID"];
        VPLRegionPromotion *promotion = [[VPLRegionPromotion alloc] initWithRegion:region
                                                                          repeatInterval:555
                                                                             enterAction:^{
                                                                             }];
        expect(promotion.showOnce).beFalsy();
    });
    
    it(@"should have the same identifier as the region's identifier", ^{
        NSUUID *testUUID = [[NSUUID alloc] initWithUUIDString:VPL_TEST_UUID];
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:testUUID identifier:@"TestID"];
        VPLRegionPromotion *promotion = [[VPLRegionPromotion alloc] initWithRegion:region
                                                                          repeatInterval:555
                                                                             enterAction:^{
                                                                             }];
        expect(promotion.identifier).to.equal(promotion.region.identifier);
    });
    

});

SpecEnd