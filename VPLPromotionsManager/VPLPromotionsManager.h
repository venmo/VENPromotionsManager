#import <Foundation/Foundation.h>
#import "VPLLocationServiceProtocol.h"
#import "NSString+VPLSanitiation.h"
#import "VPLLocationPromotion.h"
#import "VPLRegionPromotion.h"
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

///A custom (and optional) location service to be used instead of the gps service. If permission has already been granted to the app for GPS or if shouldRequestGPSAccess is YES, the GPS will always be used. The custom service cannot be used for region promotions which require the GPS service.
@property (nonatomic, strong) id<VPLLocationServiceProtocol> locationFetchServer;

///YES if the VLPPromotionsManager is checking for location based promotions at the rate specified by the refresh interval. NO otherwise.
@property (nonatomic, assign) BOOL isRunning;

//The number of seconds between location requests. This default to 60 seconds at intialization.
@property (nonatomic, assign) NSUInteger refreshInterval;


/**
 Creates a promotion object instance. If you are creating a singleton object use startWithPromotions: instead.
 @param promotions promotions array of VPLPromotion objects in order of fire priority.
 @param shouldRequestGPSAccess YES if the manager instance should ask for GPS permissions. If set to NO, the manager will use the locationFetchServer. If locationFetchServer is not set and shouldRequestGPSAccess is NO, no location requests will be made.
 @return An `VPLPromotionsManager` instance
 */
- (instancetype)initWithPromotions:(NSArray *)promotions
            shouldRequestGPSAccess:(BOOL)shouldRequestGPSAccess;


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
