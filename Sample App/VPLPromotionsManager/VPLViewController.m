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
                                                                      uniqueIdentifier:userDefaultsKey
                                                                                action:^{
                                                                                    NSLog(@"Promotion Number %ld Fired",(long)(i+1));
                                                                                }];
        promotion.showOnce = YES;
        [promotions addObject:promotion];
    }
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *doorRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major:12622
                                                                         minor:33881
                                                                    identifier:@"VenmoEntrancePromotion"];
    VPLBeaconPromotion *doorBeaconPromotion = [[VPLBeaconPromotion alloc] initWithBeaconRegion:doorRegion
                                                                                repeatInterval:2
                                                                                   enterAction:^{
                                                                                       NSString *title    = @"Welcome to Venmo!";
                                                                                       NSString *message  = @"You've just stepped into the world's most innovative office";
                                                                                       UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                                                                                       if (state == UIApplicationStateActive) {
                                                                                           [[[UIAlertView alloc] initWithTitle:title
                                                                                                                       message:message
                                                                                                                      delegate:nil
                                                                                                             cancelButtonTitle:@"OK"
                                                                                                             otherButtonTitles: nil] show];
                                                                                       }
                                                                                       else {
                                                                                           UILocalNotification *notification = [[UILocalNotification alloc] init];
                                                                                           notification.alertAction = title;
                                                                                           notification.alertBody = message;
                                                                                           [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                                                                                       }
                                                                                   }];
    [promotions addObject:doorBeaconPromotion];
    
    [VPLPromotionsManager sharedManagerWithPromotions:[promotions copy]
                                        locationTypes:VPLLocationTypeGPSRequestPermission];
    
    [VPLPromotionsManager sharedManager].refreshInterval = 2;
    [[VPLPromotionsManager sharedManager] startMonitoringForPromotionLocations];
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
