#import "VPLViewController.h"
#import "VPLAppDelegate.h"
#import "VPLPromotionsManager.h"
#import "VPLLocationPromotion.h"
#import "VPLBeaconPromotion.h"

static NSString *kVENPromotionAppleKey = @"ApplePromotionKey";

@implementation VPLViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CLLocation *appleHQLocation = [[CLLocation alloc] initWithLatitude:37.3318 longitude:-122.0312];
    NSMutableArray *promotions = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<15; i++) {
        NSString *userDefaultsKey = [NSString stringWithFormat:@"%@%ld", kVENPromotionAppleKey,(long)i];
        VPLLocationPromotion *promotion = [[VPLLocationPromotion alloc] initWithCenter:appleHQLocation
                                                                  range:3000
                                                              startDate:nil
                                                                endDate:nil
                                                showOnceUserDefaultsKey:userDefaultsKey
                                                                 action:^{
                                                                     NSLog(@"Promotion Number %ld Fired",(long)(i+1));
                                                                 }];
        [promotions addObject:promotion];
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//    CLBeaconRegion *testRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//                                                                         major:12622
//                                                                         minor:33881
//                                                                    identifier:@"EstimoteRemote"];
    CLBeaconRegion *testRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major:20874
                                                                         minor:64674
                                                                    identifier:@"EstimoteRemote"];
    
    VPLBeaconPromotion *beaconPromotion = [[VPLBeaconPromotion alloc]
                                           initWithBeaconRegion:testRegion
                                           withMaximiumProximity:CLProximityImmediate
                                           repeatInterval:10
                                           startDate:nil
                                           endDate:nil
                                           showOnceUserDefaultsKey:nil
                                           action:^{
                                               [[[UIAlertView alloc] initWithTitle:@"Welcome to Venmo!" message:@"You've just stepped into the world's most innovative office" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                                           }];
    
    [promotions addObject:beaconPromotion];
    
    [VPLPromotionsManager startWithPromotions:[promotions copy]
                                locationTypes:VPLLocationTypeGPSRequestPermission
                              locationService:nil
                          withLocationRequestInterval:5
                      withMultipleTriggerType:VPLMultipleTriggerOnRefreshTypeTriggerOnce];
    
    

    
}


- (IBAction)startStopClicked:(id)sender {
    if ([VPLPromotionsManager sharedManager].isRunning) {
        [[VPLPromotionsManager sharedManager] stopMonitoringForPromotionLocations];
    }
    else {
        [[VPLPromotionsManager sharedManager] startMonitoringForPromotionLocations];
    }
}

@end
