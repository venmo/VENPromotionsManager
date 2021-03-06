## VENPromotionsManager
[![Build Status](https://travis-ci.org/venmo/VENPromotionsManager.svg?branch=master)](https://travis-ci.org/venmo/VENPromotionsManager)

VENPromotionsManager enables easy definition, management and control of in-app location based promotions including the following:
- Define promotion action events along with trigger locations and valid date intervals
- Fire promotions on entering a geographic region or a region created by Bluetooh LE beacons, even if the app is not yet launched or is backgrounded
- Schedule location updates on a repeating timer that runs on a background queue (optional)
- Use an included location service built on a CLLocationManager or a custom location service

### Demo
<img src="example.gif" width="320">


### Installation

You can install VENPromotionsManager in your project by using [CocoaPods](https://github.com/cocoapods/cocoapods):

```Ruby
pod 'VENPromotionsManager', '~> 1.0.0'
```
### Usage

First create one (or more) promotion(s). Promotions can be either region based (using beacons or geofencing) or location based which require periodic location lookups.
```objc

//Location Promotion
VPLLocationPromotion *locationPromotion = [[VPLLocationPromotion alloc] initWithCity:@"Cupertino"
                                                                       state:@"CA"
                                                                     country:@"United States"
                                                            uniqueIdentifier:userDefaultsKey action:^{
                                                                NSLog(@"Promotion Number %ld Fired",(long)(i+1));
                                                            }];

//Beacon based Region Promotion
NSUUID *estimoteUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
CLBeaconRegion *doorRegion = [[CLBeaconRegion alloc] initWithProximityUUID:estimoteUUID
                                                                    identifier:@"VenmoEntrancePromotion"];

VPLRegionPromotion *regionPromotion = [[VPLRegionPromotion alloc] initWithRegion:doorRegion
                                                                  repeatInterval:2
                                                                    enterAction:^{
                                                                      //Implement code to launch promotion here
                                                                   }];
 ```
 
Then init the promotions manager with an array of the created promotion(s)
```objc
self.promotionsManager = [[VPLPromotionsManager alloc] initWithPromotions:@[locationPromotion, regionPromotion]
                                                   shouldRequestGPSAccess:YES];
self.promotionsManager.refreshInterval = 60 * 60; //Lookup location every 60 minutes
[self.promotionsManager startMonitoringForPromotionLocations];
 ```

In this example, the VPLPromotionsManager instance will perform a location lookup and trigger any valid location promotion every 60 minutes and will trigger any valid region promotions whenever it enters the promotion's region. Region promotions support background notifications, while location promotions do not.

### Contributing

We'd love to see your ideas for improving VENPromotionsManager! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a new Github issue if you find bugs or have questions. 

Please make sure to follow our general coding style and add test coverage for new features!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
