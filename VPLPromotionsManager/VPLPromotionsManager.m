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
@property (nonatomic, assign) NSUInteger refreshInterval;
@property (nonatomic, strong) NSMutableArray *locationPromotions;
@property (nonatomic, strong) NSMutableDictionary *beaconPromotions;
@property (nonatomic, assign) VPLLocationType types;
@property (nonatomic, assign) VPLMultipleTriggerOnRefreshType multipleTriggerType;
@property (nonatomic, copy) VPLGCDtimerTick promotionCheckTimerTick;
@property (nonatomic, assign) CLLocationAccuracy gpsDesiredLocationAccuracy;
@property (nonatomic, assign) CGFloat gpsMinimumHorizontalAccuracy;

@end

@implementation VPLPromotionsManager

+ (instancetype)startWithPromotions:(NSArray *)promotions
                                locationTypes:(VPLLocationType)types
                              locationService:(id<VPLLocationServiceProtocol>)locationService
                          withLocationRequestInterval:(NSUInteger)seconds
                      withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType {
    
    static dispatch_once_t promotionManagerCreationToken = 0;
    dispatch_once(&promotionManagerCreationToken, ^{
        promotionsManager = [[self alloc] initWithPromotions:promotions
                                               locationTypes:types
                                             locationService:locationService
                                         withLocationRequestInterval:seconds
                                     withMultipleTriggerType:multipleTriggerType];
        [promotionsManager startMonitoringForPromotionLocations];
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
                     locationTypes:(VPLLocationType)types
                   locationService:(id<VPLLocationServiceProtocol>)locationService
               withLocationRequestInterval:(NSUInteger)seconds
           withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType {
    self = [super init];
    if (self){
        self.types = types;
        self.locationService = locationService;
        self.refreshInterval = seconds;
        self.multipleTriggerType = multipleTriggerType;
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
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSString *showOnceUserDefaultsKey = [timeValidPromotion showOnceUserDefaultsKey];
                            if (showOnceUserDefaultsKey) {
                                [userDefaults setBool:YES forKey:showOnceUserDefaultsKey];
                                [userDefaults synchronize];
                            }
                            [weakSelf.locationPromotions removeObject:timeValidPromotion];
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
            if(!showOnceUserDefaultsKey) {
                [self queuePromotion:promotion];
            }
            else {
                if (![userDefaults boolForKey:showOnceUserDefaultsKey]) {
                    [self queuePromotion:promotion];
                }
            }
        }
    }
    if ([self.beaconPromotions count]) {
        [self createGPSLocationServiceIfPossible];
        if (self.gpsService) {
            __weak VPLPromotionsManager *weakSelf = self;
            self.gpsService.regionFoundCallback = ^(CLBeaconRegion *region, NSArray *beacons, NSError *error) {
                if (!error) {
                    [weakSelf triggerValidPromotionInRegion:region withBeacons:beacons];
                }
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

- (void)triggerValidPromotionInRegion:(CLRegion *)region withBeacons:(NSArray *)beacons {
    VPLBeaconPromotion *promotion = self.beaconPromotions[region.identifier];
    if (promotion) {
        if ([promotion shouldTriggerOnDate:[NSDate date]]) {
        BOOL beaconIsInProximityRange;
        for (CLBeacon *beacon in beacons) {
            CLProximity proximity = beacon.proximity;
            if (proximity <= promotion.maximumProximity && proximity != CLProximityUnknown) {
                beaconIsInProximityRange = YES;
                break;
            }
        }
        if (beaconIsInProximityRange) {
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
}

@end
