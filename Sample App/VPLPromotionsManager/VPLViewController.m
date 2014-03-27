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
                                                                          showOnlyOnce:YES
                                                                             startDate:nil
                                                                               endDate:nil
                                                                                action:^{
                                                                                    NSLog(@"Promotion Number %ld Fired",(long)(i+1));
                                                                                }];
        [promotions addObject:promotion];
    }
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconRegion *doorRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major:12622
                                                                         minor:33881
                                                                    identifier:@"DoorEstimoteRemote"];
    CLBeaconRegion *deskRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                         major:20874
                                                                         minor:64674
                                                                    identifier:@"DeskEstimoteRemote"];
    
    VPLBeaconPromotion *deskBeaconPromotion =
    [[VPLBeaconPromotion alloc]
     initWithBeaconRegion:deskRegion
     withMaximiumProximity:CLProximityImmediate
     repeatInterval:2
     startDate:nil
     endDate:nil
     showOnlyOnce:YES
     action:^{
         NSString *title    = @"Welcome to Chris's Desk!";
         NSString *message  = @"This is the future of Venmo Mobile";
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
    
    VPLBeaconPromotion *doorBeaconPromotion =
    [[VPLBeaconPromotion alloc]
     initWithBeaconRegion:doorRegion
     withMaximiumProximity:CLProximityImmediate
     repeatInterval:2
     startDate:nil
     endDate:nil
     showOnlyOnce:NO
     action:^{
         NSLog(@"TRIGGERED");
         
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
    
    [promotions addObject:deskBeaconPromotion];
    [promotions addObject:doorBeaconPromotion];

    
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
