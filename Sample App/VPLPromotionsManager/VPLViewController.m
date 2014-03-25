#import "VPLViewController.h"
#import "VPLAppDelegate.h"
#import "VPLPromotionsManager.h"
#import "VPLLocationPromotion.h"

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
                                                                     NSLog(@"Promotion Number %ld Fired",(i+1));
                                                                 }];
        [promotions addObject:promotion];
    }
    [VPLPromotionsManager startWithPromotions:[promotions copy]
                                locationTypes:VPLLocationTypeGPSRequestPermission
                              locationService:nil
                          withRefreshInterval:5
                      withMultipleTriggerType:VPLMultipleTriggerOnRefreshTypeTriggerOnce];
    
    
    NSUUID *uuid1 = [[NSUUID alloc] initWithUUIDString:@"DED1F934-59A0-4511-901F-756A2B66538C"];
    CLBeaconRegion *region1 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid1 major:100 minor:20 identifier:@"com.dasmer"];
    
    NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString:@"DED1F934f-59A0-4511-901F-756A2B66538C"];
    CLBeaconRegion *region2 = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2 major:100 minor:20 identifier:@"com.dasmer"];
    
    
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
