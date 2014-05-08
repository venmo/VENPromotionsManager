#import "VPLPromotionsManager.h"
#import "VPLPromotionLocationGPSService.h"

#define DefaultGPSDesiredAccuracy kCLLocationAccuracyBest;
#define DefaultGPSMinimumHorizontalAccuracy 5000;

typedef void (^VPLGCDtimerTick)(void);

const NSInteger VPLPromotionsManagerRefreshIntervalNone = 0;
static VPLPromotionsManager *promotionsManager = nil;

@interface VPLPromotionsManager()

@property (nonatomic, strong) VPLPromotionLocationGPSService<VPLLocationServiceProtocol> *gpsService;
@property (nonatomic, strong) NSMutableArray *locationPromotions;
@property (nonatomic, strong) NSMutableDictionary *regionPromotions;
@property (nonatomic, assign) VPLMultipleTriggerOnRefreshType multipleTriggerType;
@property (nonatomic, copy) VPLGCDtimerTick promotionCheckTimerTick;
@property (nonatomic, assign) CLLocationAccuracy gpsDesiredLocationAccuracy;
@property (nonatomic, assign) CGFloat gpsMinimumHorizontalAccuracy;

@end

@implementation VPLPromotionsManager

- (instancetype)init {
    self = [super init];
    if (self){
        promotionsManager.refreshInterval   = 60;
        self.gpsDesiredLocationAccuracy     = DefaultGPSDesiredAccuracy;
        self.gpsMinimumHorizontalAccuracy   = DefaultGPSMinimumHorizontalAccuracy;
    }
    return self;
}

- (instancetype)initWithPromotions:(NSArray *)promotions
            shouldRequestGPSAccess:(BOOL)shouldRequestGPSAccess {
    self = [self init];
    if (self){
        self.shouldRequestGPSAccess = shouldRequestGPSAccess;
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
        id<VPLLocationServiceProtocol> currentService = self.gpsService ? self.gpsService : self.locationFetchServer;
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
                VPLPromotionsManager *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if (!error){
                    for (VPLLocationPromotion *timeValidPromotion in currentTimeValidPromotions) {
                        if ([timeValidPromotion shouldTriggerOnDate:now atLocation:currentLocation]) {
                            [timeValidPromotion triggerPromotion];
                            [strongSelf.locationPromotions removeObject:timeValidPromotion];
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSString *showOnceUserDefaultsKey = [timeValidPromotion showOnceUserDefaultsKey];
                            if (showOnceUserDefaultsKey) {
                                [userDefaults setBool:YES forKey:showOnceUserDefaultsKey];
                                [userDefaults synchronize];
                            }
                            else {
                                [strongSelf.locationPromotions addObject:timeValidPromotion];
                            }
                            if (strongSelf.multipleTriggerType == VPLMultipleTriggerOnRefreshTypeTriggerOnce) {
                                break;
                            }
                        }
                    }
                    if (![strongSelf.locationPromotions count]) {
                        [strongSelf stopMonitoringForPromotionLocations];
                    }
                }
            }];
        }
    }
}


#pragma mark - Setters

- (void)setPromotions:(NSArray *)promotions {
    self.locationPromotions = [[NSMutableArray alloc] init];
    self.regionPromotions = [[NSMutableDictionary alloc] init];
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
    if ([self.regionPromotions count]) {
        [self createGPSLocationServiceIfPossible];
        if (self.gpsService) {
            __weak VPLPromotionsManager *weakSelf = self;
            self.gpsService.regionEnteredCallback =  ^(CLRegion *region) {
                VPLPromotionsManager *strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf triggerValidPromotionInRegion:region];
            };
            NSArray *regionIdentifiers = [self.regionPromotions allKeys];
            for (id identifier in regionIdentifiers) {
                if ([identifier isKindOfClass:[NSString class]]) {
                    VPLRegionPromotion *regionPromotion = self.regionPromotions[identifier];
                    if ([CLLocationManager isMonitoringAvailableForClass:[regionPromotion.region class]]) {
                        [self.gpsService startMonitoringForRegion:regionPromotion.region];
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
    else if ([promotion isKindOfClass:[VPLRegionPromotion class]]) {
        VPLRegionPromotion *regionPromotion = (VPLRegionPromotion *)promotion;
        [self.regionPromotions setObject:regionPromotion forKey:regionPromotion.region.identifier];
    }
}

- (void)createGPSLocationServiceIfPossible{
    if (self.shouldRequestGPSAccess || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            self.gpsService = [[VPLPromotionLocationGPSService alloc] initWithLocationAccuracy:self.gpsDesiredLocationAccuracy minimumHorizontalAccuracy:self.gpsMinimumHorizontalAccuracy];
        }
}

#pragma mark - Region Methods

- (void)triggerValidPromotionInRegion:(CLRegion *)region {
    VPLRegionPromotion *promotion = self.regionPromotions[region.identifier];
    if (promotion) {
        if ([promotion shouldTriggerOnDate:[NSDate date]]) {
            [promotion triggerPromotion];
            NSString *showOnceUserDefaultsKey = [promotion showOnceUserDefaultsKey];
            if (showOnceUserDefaultsKey) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:showOnceUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (promotion.repeatInterval == NSIntegerMax || showOnceUserDefaultsKey) {
                [self.regionPromotions removeObjectForKey:region.identifier];
                [self.gpsService stopMonitoringForRegion:region];
                
            }
        }
    }
}

@end
