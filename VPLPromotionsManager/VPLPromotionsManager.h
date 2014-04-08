#import <Foundation/Foundation.h>
#import "VPLLocationServiceProtocol.h"
#import "NSString+VPLSanitiation.h"
#import "VPLPromotion.h"
#import "VPLLocation.h"

/**
 `VPLPromotionsManager` fires an array of VPLPromotions based on user location at regularly specified intervals or by a manual call to check for a location match.
 */
@interface VPLPromotionsManager : NSObject

extern const NSInteger VPLPromotionsManagerRefreshIntervalNone;

typedef NS_ENUM(NSUInteger, VPLMultipleTriggerOnRefreshType) {
    VPLMultipleTriggerOnRefreshTypeTriggerOnce,
    VPLMultipleTriggerOnRefreshTypeTriggerAll
};


typedef NS_OPTIONS(NSUInteger, VPLLocationType) {
    VPLLocationTypeService,
    VPLLocationTypeGPSIfPermissionGranted,
    VPLLocationTypeGPSRequestPermission
};

///YES if the VLPPromotionsManager is checking for location based promotions at the rate specified by the refresh interval. NO otherwise.
@property (nonatomic, assign) BOOL isRunning;

//The number of seconds between location requests
@property (nonatomic, assign) NSUInteger refreshInterval;


/**
 Creates a promotion object instance. If you are creating a singleton object use startWithPromotions: instead.
 @param promotions promotions array of VPLPromotion objects in order of fire priority.
 @param types the type of location services that should be used in order to fire the promotion
 @return An `VPLPromotionsManager` instance
 */
- (instancetype)initWithPromotions:(NSArray *)promotions
                     locationTypes:(VPLLocationType)types;


/**
 Begins monitoring for location based promotions at the the refresh rate rate specified during initialization. This function does not repeat if refresh rate was set to VPLPromotionsManagerRefreshIntervalNone.  This is also automatically called in startWithPromotions:
 */
- (void)startMonitoringForPromotionLocations;


/**
 Stops repeatedly checking for promotions.
 */
- (void)stopMonitoringForPromotionLocations;


/**
 Checks if user's current location should fire any location promotion(s) manually. This is automatically called at regular intervals after startMonitoringForPromotionLocations.
 */
- (void)checkForLocationBasedPromotions;

@end
