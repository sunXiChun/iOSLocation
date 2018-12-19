//
//  LocationManager.h
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>

@optional
- (void)locationManager:(id)locationManager didUpdateLocation:(CLLocation *)location;
- (void)locationManager:(id)locationManager didEnterRegion:(CLRegion *)region;
- (void)locationManager:(id)locationManager didLeaveRegion:(CLRegion *)region;
- (void)locationManager:(id)locationManager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region;
- (void)locationManager:(id)locationManager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error;
- (void)locationManager:(id)locationManager didUpdateHeading:(CLHeading *)newHeading;

- (void)locationDidChangeAuthorizationStatus:(BOOL)isAuthorized;

@end

@interface LocationManager : NSObject

@property (strong,nonatomic) CLLocationManager *locationManager;
@property (weak  ,nonatomic) id<LocationDelegate> delegate;

+ (LocationManager *)locationManagerWithDelegate:(id<LocationDelegate>)delegate;

- (void)startOnceLocation;

- (void)stopOnceLocation;

- (void)startUpdatingLocation;

- (void)stopUpdatingLocation;

- (void)startMonitoringLocation;

- (void)stopMonitoringLocation;

- (void)startUpdatingHeading;

- (void)stopUpdatingHeading;

- (void)startMonitoringVisits;

- (void)startMonitoringForRegion:(CLLocationCoordinate2D)coordinate2D radius:(CLLocationDistance)radius;

- (void)stopMonitoringForRegion:(CLLocationCoordinate2D)coordinate2D radius:(CLLocationDistance)radius;

- (void)startRangingBeacons:(CLBeaconRegion *)region;

- (void)stopRangingBeacons:(CLBeaconRegion *)region;

@end
