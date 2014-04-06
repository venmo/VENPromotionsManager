#import "VPLPromotionsManager.h"
#import "VPLPromotionLocationGPSService.h"
#import "VPLLocationPromotion.h"
#import "VPLBeaconPromotion.h"

#define DefaultGPSDesiredAccuracy kCLLocationAccuracyBest;
#define DefaultGPSMinimumHorizontalAccuracy 5000;

typedef void (^VPLGCDtimerTick)(void);

const NSInteger VPLPromotionsManagerRefreshIntervalNone = 0;
static VPLPromotionsManager *promotionsManager = nil;

@interface VPLPromotionsManager()

@property (nonatomic, strong) id<VPLLocationServiceProtocol> locationService;
@property (nonatomic, strong) VPLPromotionLocationGPSService<VPLLocationServiceProtocol> *gpsService;
@property (nonatomic, strong) NSMutableArray *locationPromotions;
@property (nonatomic, strong) NSMutableDictionary *beaconPromotions;
@property (nonatomic, assign) VPLLocationType types;
@property (nonatomic, assign) VPLMultipleTriggerOnRefreshType multipleTriggerType;
@property (nonatomic, copy) VPLGCDtimerTick promotionCheckTimerTick;
@property (nonatomic, assign) CLLocationAccuracy gpsDesiredLocationAccuracy;
@property (nonatomic, assign) CGFloat gpsMinimumHorizontalAccuracy;

@end

@implementation VPLPromotionsManager

+ (instancetype)sharedManagerWithPromotions:(NSArray *)promotions
                              locationTypes:(VPLLocationType)types {
    
    static dispatch_once_t promotionManagerCreationToken = 0;
    dispatch_once(&promotionManagerCreationToken, ^{
        promotionsManager = [[self alloc] initWithPromotions:promotions
                                               locationTypes:types];
    });
    return promotionsManager;
}


+ (instancetype)sharedManager {
    return promotionsManager;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWithPromotions:(NSArray *)promotions
                     locationTypes:(VPLLocationType)types {
    self = [super init];
    if (self){
        self.types = types;
        promotionsManager.refreshInterval = 60 * 60 * 24; //24 hours
        self.gpsDesiredLocationAccuracy = DefaultGPSDesiredAccuracy;
        self.gpsMinimumHorizontalAccuracy = DefaultGPSMinimumHorizontalAccuracy;
        [self setPromotions:promotions];

    }
    return self;
}


- (void)startMonitoringForPromotionLocations {
    if (self.refreshInterval != VPLPromotionsManagerRefreshIntervalNone) {
        __weak VPLPromotionsManager *weakSelf = self;
        self.promotionCheckTimerTick = ^{
            [weakSelf checkForLocationBasedPromotions];
            double delayInSeconds = 1.0f * weakSelf.refreshInterval;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                VPLPromotionsManager *strongSelf = weakSelf;
                if (strongSelf.promotionCheckTimerTick) {
                    strongSelf.promotionCheckTimerTick();
                }
            });
        };
        self.promotionCheckTimerTick();
        self.isRunning = YES;
    }
}


- (void)stopMonitoringForPromotionLocations {
    if (self.promotionCheckTimerTick) {
        self.promotionCheckTimerTick = nil;
    }
    self.isRunning = NO;
}


- (void)checkForLocationBasedPromotions {
    if ([self.locationPromotions count]) {
        if (!self.gpsService) {
            [self createGPSLocationServiceIfPossible];
        }
        id<VPLLocationServiceProtocol> currentService = self.gpsService ? self.gpsService : self.locationService;
        NSDate *now = [NSDate date];
        NSMutableArray *currentTimeValidPromotions = [[NSMutableArray alloc] init];
        for (VPLPromotion *promotion in self.locationPromotions) {
            if ([promotion shouldTriggerOnDate:now]) {
                [currentTimeValidPromotions addObject:promotion];
            }
        }
        if (currentService && [currentTimeValidPromotions count]) {
            __weak VPLPromotionsManager *weakSelf = self;
            [currentService requestCurrentLocationWithCompletion:^(VPLLocation *currentLocation, NSError *error) {
                if (!error){
                    for (VPLLocationPromotion *timeValidPromotion in currentTimeValidPromotions) {
                        if ([timeValidPromotion shouldTriggerOnDate:now atLocation:currentLocation]) {
                            [timeValidPromotion triggerPromotion];
                            [weakSelf.locationPromotions removeObject:timeValidPromotion];
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSString *showOnceUserDefaultsKey = [timeValidPromotion showOnceUserDefaultsKey];
                            if (showOnceUserDefaultsKey) {
                                [userDefaults setBool:YES forKey:showOnceUserDefaultsKey];
                                [userDefaults synchronize];
                            }
                            else {
                                [weakSelf.locationPromotions addObject:timeValidPromotion];
                            }
                            if (self.multipleTriggerType == VPLMultipleTriggerOnRefreshTypeTriggerOnce) {
                                break;
                            }
                        }
                    }
                    if (![weakSelf.locationPromotions count]) {
                        [self stopMonitoringForPromotionLocations];
                    }
                }
            }];
        }
    }
}


#pragma mark - Setters

- (void)setPromotions:(NSArray *)promotions {
    self.locationPromotions = [[NSMutableArray alloc] init];
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        self.beaconPromotions = [[NSMutableDictionary alloc] init];
    }
    NSDate *currentDate = [NSDate date];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (VPLPromotion *promotion in promotions){
        if ([promotion canTriggerInFutureForCurrentDate:currentDate]) {
            NSString *showOnceUserDefaultsKey = [promotion showOnceUserDefaultsKey];
            if(!showOnceUserDefaultsKey ||![userDefaults boolForKey:showOnceUserDefaultsKey]) {
                [self queuePromotion:promotion];
            }
        }
    }
    if ([self.beaconPromotions count]) {
        [self createGPSLocationServiceIfPossible];
        if (self.gpsService) {
            __weak VPLPromotionsManager *weakSelf = self;
            self.gpsService.regionEnteredCallback =  ^(CLRegion *region) {
                [weakSelf triggerValidPromotionInRegion:region];
            };
            NSArray *regionIdentifiers = [self.beaconPromotions allKeys];
            for (id identifier in regionIdentifiers) {
                if ([identifier isKindOfClass:[NSString class]]) {
                    VPLBeaconPromotion *beaconPromotion = self.beaconPromotions[identifier];
                    if (beaconPromotion) {
                        [self.gpsService startMonitoringForRegion:beaconPromotion.beaconRegion];
                    }
                }
            }
        }
    }
}


#pragma mark - Custom Private Methods

- (void)queuePromotion:(VPLPromotion *)promotion{
    if ([promotion isKindOfClass:[VPLLocationPromotion class]]) {
        [self.locationPromotions addObject:promotion];
    }
    else if ([promotion isKindOfClass:[VPLBeaconPromotion class]]) {
        VPLBeaconPromotion *beaconPromotion = (VPLBeaconPromotion *)promotion;
        [self.beaconPromotions setObject:beaconPromotion forKey:beaconPromotion.beaconRegion.identifier];
    }
}

- (void)createGPSLocationServiceIfPossible{
    if ((self.types & VPLLocationTypeGPSRequestPermission)
        || (self.types & VPLLocationTypeGPSIfPermissionGranted
            && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
            self.gpsService = [[VPLPromotionLocationGPSService alloc] initWithLocationAccuracy:self.gpsDesiredLocationAccuracy minimumHorizontalAccuracy:self.gpsMinimumHorizontalAccuracy];
        }
}

#pragma mark - Beacon Methods

- (void)triggerValidPromotionInRegion:(CLRegion *)region {
    VPLBeaconPromotion *promotion = self.beaconPromotions[region.identifier];
    if (promotion) {
        if ([promotion shouldTriggerOnDate:[NSDate date]]) {
            [promotion triggerPromotion];
            NSString *showOnceUserDefaultsKey = [promotion showOnceUserDefaultsKey];
            if (showOnceUserDefaultsKey) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:showOnceUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (promotion.repeatInterval == NSIntegerMax || showOnceUserDefaultsKey) {
                [self.beaconPromotions removeObjectForKey:region.identifier];
                [self.gpsService stopMonitoringForRegion:region];
                
            }
        }
    }
}

@end
