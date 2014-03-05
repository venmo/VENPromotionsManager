#import "VPLViewController.h"
#import "VPLAppDelegate.h"
#import "VPLPromotionsManager.h"


static NSString *kVENPromotionAppleKey = @"ApplePromotionKey";

@implementation VPLViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CLLocation *appleHQLocation = [[CLLocation alloc] initWithLatitude:37.3318 longitude:-122.0312];
    
    NSMutableArray *promotions = [[NSMutableArray alloc] init];
    
    for (NSInteger i=0; i<15; i++) {
        NSString *userDefaultsKey = [NSString stringWithFormat:@"%@%d", kVENPromotionAppleKey,i];
        VPLPromotion *promotion = [[VPLPromotion alloc] initWithCenter:appleHQLocation
                                                                  range:3000
                                                              startDate:nil
                                                                endDate:nil
                                                showOnceUserDefaultsKey:userDefaultsKey
                                                                 action:^{
                                                                     NSLog(@"Promotion Number %d Fired",(i+1));
                                                                 }];
        [promotions addObject:promotion];
    }
    
    [VPLPromotionsManager startWithPromotions:[promotions copy]
                                locationTypes:VPLLocationTypeGPSRequestPermission
                              locationService:nil
                          withRefreshInterval:5 withMultipleTriggerType:VPLMultipleTriggerOnRefreshTypeTriggerOnce];
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
