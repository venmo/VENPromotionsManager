#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+VPLSanitiation.h"

extern NSString *VPLLocationCityKey;
extern NSString *VPLLocationStateKey;
extern NSString *VPLLocationCountryKey;

/**
 `VPLLocation` is an object that should be created by a VPLLocationService. It should contain either a city, state, and country or a location created by latitude and longitude coordiantes.
 */
@interface VPLLocation : NSObject

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;

- (instancetype)initWithLocationDictionary:(NSDictionary *)userLocation;

/**
 @return YES if the VPLLocation contains either a city, state, and country or a location created by latitude and longitude coordiantes.
*/
- (BOOL)isValid;

@end
