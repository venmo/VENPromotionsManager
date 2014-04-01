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
 Creates and starts a Promotion Manager singleton object.
 @param promotions promotions array of VPLPromotion objects in order of fire priority.
 @param types the type of location services that should be used in order to fire the promotion. This must be VPLLocationTypeGPSIfPermissionGranted or VPLLocationTypeGPSRequestPermission for beacon promotions to trigger.
 @param locationService locationService a object that conforms to the VPLLocationServiceProtocol protocol. One can use the VPLPromotionLocationGPSService or supply a custom object.
 @param seconds the number of seconds between location checks to fire promotions. To disable repeated checks, specify VPLPromotionsManagerRefreshIntervalNone,
 @param multipleTriggerType the way in which the promotion manager handles multiple vaild fires on one check. By default, it fires at maximum only one promotion per check.
 @return An `VPLPromotionsManager` singleton object
 */
+ (instancetype)startWithPromotions:(NSArray *)promotions
                      locationTypes:(VPLLocationType)types
            withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType;


/**
 A reference to the shared instance of the Promotion Manager. This should be called each time after and only after startWithPromotions: is called.
 */
+ (instancetype)sharedManager;


/**
 Creates a promotion object instance. If you are creating a singleton object use startWithPromotions: instead.
 @param promotions promotions array of VPLPromotion objects in order of fire priority.
 @param types the type of location services that should be used in order to fire the promotion
 @param locationService locationService a object that conforms to the VPLLocationServiceProtocol protocol. One can use the VPLPromotionLocationGPSService or supply a custom object.
 @param seconds the number of seconds between location checks to fire promotions. To disable repeated checks, specify VPLPromotionsManagerRefreshIntervalNone,
 @param multipleTriggerType the way in which the promotion manager handles multiple vaild fires on one check. By default, it fires at maximum only one promotion per check.
 @return An `VPLPromotionsManager` instance
 */
- (instancetype)initWithPromotions:(NSArray *)promotions
                     locationTypes:(VPLLocationType)types
           withMultipleTriggerType:(VPLMultipleTriggerOnRefreshType)multipleTriggerType;


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
