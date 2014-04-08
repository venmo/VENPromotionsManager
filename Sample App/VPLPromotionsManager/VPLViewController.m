#import "VPLViewController.h"
#import "VPLAppDelegate.h"
#import "VPLPromotionsManager.h"
#import "VPLLocationPromotion.h"
#import "VPLRegionPromotion.h"

static NSString *kVENPromotionAppleKey = @"ApplePromotionKey";

@interface VPLViewController ()

@property (nonatomic, strong) VPLPromotionsManager *promotionsManager;

@end

@implementation VPLViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CLLocation *appleHQLocation = [[CLLocation alloc] initWithLatitude:37.3318
                                                             longitude:-122.0312];
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
                                                                    identifier:@"VenmoEntrancePromotion"];
    VPLPromotionAction doorEnterAction = ^{
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
    };

    VPLRegionPromotion *doorBeaconPromotion = [[VPLRegionPromotion alloc] initWithRegion:doorRegion
                                                                                repeatInterval:2
                                                                                   enterAction:doorEnterAction];

    [promotions addObject:doorBeaconPromotion];
    
    self.promotionsManager = [[VPLPromotionsManager alloc] initWithPromotions:[promotions copy]
                                                       shouldRequestGPSAccess:YES];
    self.promotionsManager.refreshInterval = 2;
    [self.promotionsManager startMonitoringForPromotionLocations];
}


- (IBAction)startStopClicked:(id)sender {
    if (self.promotionsManager.isRunning) {
        [self.promotionsManager stopMonitoringForPromotionLocations];
    }
    else {
        [self.promotionsManager startMonitoringForPromotionLocations];
    }
}

@end
