#import "VPLPromotionsManager.h"
#import "VPLPromotionLocationGPSService.h"

#define DefaultGPSDesiredAccuracy kCLLocationAccuracyBest;
#define DefaultGPSMinimumHorizontalAccuracy 5000;

typedef void (^VPLGCDtimerTick)(void);

const NSInteger VPLPromotionsManagerRefreshIntervalNone = 0;
static VPLPromotionsManager *promotionsManager = nil;

@interface VPLPromotionsManager()

@property (nonatomic, strong) id<VPLLocationServiceProtocol> locationService;
@property (nonatomic, strong) VPLPromotionLocationGPSService<VPLLocationServiceProtocol> *gpsService;
@property (nonatomic, assign) NSUInteger refreshInterval;
@property (nonatomic, strong) NSMutableArray *promotions;
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
                          withRefreshInterval:(NSUInteger)seconds
                      withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType {
    
    static dispatch_once_t promotionManagerCreationToken = 0;
    dispatch_once(&promotionManagerCreationToken, ^{
        promotionsManager = [[self alloc] initWithPromotions:promotions
                                               locationTypes:types
                                             locationService:locationService
                                         withRefreshInterval:seconds
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
               withRefreshInterval:(NSUInteger)seconds
           withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType {
    self = [super init];
    if (self){
        self.promotions = [promotions mutableCopy];
        self.types = types;
        self.locationService = locationService;
        self.refreshInterval = seconds;
        self.multipleTriggerType = multipleTriggerType;
        self.gpsDesiredLocationAccuracy = DefaultGPSDesiredAccuracy;
        self.gpsMinimumHorizontalAccuracy = DefaultGPSMinimumHorizontalAccuracy;
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
    if ([self.promotions count]) {
        if (!self.gpsService) {
            if ((self.types & VPLLocationTypeGPSRequestPermission)
                || (self.types & VPLLocationTypeGPSIfPermissionGranted
                    && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
                    
                    self.gpsService = [[VPLPromotionLocationGPSService alloc] initWithLocationAccuracy:self.gpsDesiredLocationAccuracy andMinimumHorizontalAccuracy:self.gpsMinimumHorizontalAccuracy];

                }
        }
        id<VPLLocationServiceProtocol> currentService = self.gpsService ? self.gpsService : self.locationService;
        NSDate *now = [NSDate date];
        NSMutableArray *currentTimeValidPromotions = [[NSMutableArray alloc] init];
        for (VPLPromotion *promotion in self.promotions) {
            if ([promotion shouldTriggerOnDate:now]) {
                [currentTimeValidPromotions addObject:promotion];
            }
        }
        if (currentService && [currentTimeValidPromotions count]) {
            __weak VPLPromotionsManager *weakSelf = self;
            [currentService requestCurrentLocationWithCompletion:^(VPLLocation *currentLocation, NSError *error) {
                if (!error){
                    for (VPLPromotion *timeValidPromotion in currentTimeValidPromotions) {
                        if ([timeValidPromotion shouldTriggerOnDate:now atLocation:currentLocation]) {
                            [timeValidPromotion triggerPromotion];
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            NSString *showOnceUserDefaultsKey = timeValidPromotion.showOnceUserDefaultsKey;
                            if (timeValidPromotion.showOnceUserDefaultsKey) {
                                [userDefaults setBool:YES forKey:showOnceUserDefaultsKey];
                                [userDefaults synchronize];
                            }
                            [weakSelf.promotions removeObject:timeValidPromotion];
                            if (self.multipleTriggerType == VPLMultipleTriggerOnRefreshTypeTriggerOnce) {
                                break;
                            }
                        }
                    }
                    if (![weakSelf.promotions count]) {
                        [self stopMonitoringForPromotionLocations];
                    }
                }
            }];
        }
    }
}


#pragma mark - Setters

- (void)setPromotions:(NSMutableArray *)promotions {
    _promotions = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (VPLPromotion *promotion in promotions){
        NSString *showOnceUserDefaultsKey = promotion.showOnceUserDefaultsKey;
        if(!showOnceUserDefaultsKey) {
            [_promotions addObject:promotion];
        }
        else {
            if (![userDefaults boolForKey:showOnceUserDefaultsKey]) {
                [_promotions addObject:promotion];
            }
        }
    }
}

@end
