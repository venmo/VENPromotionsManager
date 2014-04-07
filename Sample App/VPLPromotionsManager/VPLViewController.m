#import "VPLViewController.h"
#import "VPLAppDelegate.h"
#import "VPLPromotionsManager.h"
#import "VPLLocationPromotion.h"
#import "VPLRegionPromotion.h"

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
    
    NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *doorRegion = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                                         major:12622
                                                                         minor:33881
                                                                    identifier:@"VenmoEntrancePromotion"];
    VPLRegionPromotion *doorBeaconPromotion = [[VPLRegionPromotion alloc] initWithRegion:doorRegion
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
    
    NSUUID *registerUUID = [[NSUUID alloc] initWithUUIDString:@"6F25DEE9-7874-4FA1-B876-FFE11245BD0D"];
    CLBeaconRegion *registerRegion = [[CLBeaconRegion alloc] initWithProximityUUID:registerUUID
                                                                    identifier:@"VenmoRegisterBeacon"];
    
    
    VPLRegionPromotion *registerBeaconPromotion = [[VPLRegionPromotion alloc] initWithRegion:registerRegion
                                                                          repeatInterval:10
                                                                             enterAction:^{
                                                                                 NSString *title    = @"You just passed a Venmo Register";
                                                                                 NSString *message  = @"Use your Venmo balance to pay!";
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
    [promotions addObject:registerBeaconPromotion];
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
