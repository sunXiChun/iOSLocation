//
//  LocationManager.m
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>

@end

@implementation LocationManager

+ (LocationManager *)locationManagerWithDelegate:(id<LocationDelegate>)delegate
{
    LocationManager *manager = [[LocationManager alloc] init];
    manager.delegate = delegate;
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate        = self;
        _locationManager.activityType    = CLActivityTypeAutomotiveNavigation;
        _locationManager.distanceFilter  = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        
        if (@available(iOS 11.0, *)) {
            _locationManager.showsBackgroundLocationIndicator = NO;
        }
    }
    return self;
}

- (void)startOnceLocation
{
    [self.locationManager requestLocation];
}

- (void)stopOnceLocation
{
    
}

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
}

- (void)startMonitoringLocation
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)startUpdatingHeading;
{
    [self.locationManager startUpdatingHeading];
}

- (void)stopUpdatingHeading
{
    [self.locationManager stopUpdatingHeading];
    [self.locationManager dismissHeadingCalibrationDisplay];
}

- (void)startMonitoringVisits
{
    [self.locationManager startMonitoringVisits];
}

- (void)startMonitoringForRegion:(CLLocationCoordinate2D)coordinate2D radius:(CLLocationDistance)radius {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate2D radius:radius identifier:@"Monitoring"];
    [self.locationManager startMonitoringForRegion:region];
}

- (void)stopMonitoringForRegion:(CLLocationCoordinate2D)coordinate2D radius:(CLLocationDistance)radius {
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate2D radius:radius identifier:@"Monitoring"];
    [self.locationManager stopMonitoringForRegion:region];
}

- (void)startRangingBeacons:(CLBeaconRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:region];
}

- (void)stopRangingBeacons:(CLBeaconRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:region];
}

- (void)checkAuthorizationStatus
{
    BOOL isOpen = [CLLocationManager locationServicesEnabled];
    
    if (isOpen) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        [self dealAuthorizationStatus:status];
    }else
    {
        [self callBackIsAuthorized:NO];
    }
}

- (void)dealAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined :
        {
            [self.locationManager requestAlwaysAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [self callBackIsAuthorized:NO];
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self callBackIsAuthorized:YES];
            break;
        }
    }
}

#pragma mark - callBack

- (void)callBackIsAuthorized:(BOOL)isAuthorized
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationDidChangeAuthorizationStatus:)]) {
        [self.delegate locationDidChangeAuthorizationStatus:isAuthorized];
    }
}

- (void)callBackDidUpdate:(CLLocation *)location
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocation:)]) {
        [self.delegate locationManager:self didUpdateLocation:location];
    }
}

- (void)callBackEnterRegion:(CLRegion *)region
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.delegate locationManager:self didEnterRegion:region];
    }
}

- (void)callBackLeaveRegion:(CLRegion *)region
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self.delegate locationManager:self didLeaveRegion:region];
    }
}

- (void)callBackBeaconRegion:(CLRegion *)region beacons:(NSArray *)beacons
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didRangeBeacons:inRegion:)]) {
        [self.delegate locationManager:self didRangeBeacons:beacons inRegion:(CLBeaconRegion *)region];
    }
}

- (void)callBackBeaconRegionFail:(NSError *)err
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:rangingBeaconsDidFailForRegion:withError:)]) {
        [self.delegate locationManager:self rangingBeaconsDidFailForRegion:nil withError:err];
    }
}

- (void)callBackUpdateHeading:(CLHeading *)head
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
        [self.delegate locationManager:self didUpdateHeading:head];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"#location# didUpdateLocations");
    
    CLLocation *newLocation = [locations firstObject];
    [self callBackDidUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"#location# FailWithError %@",error);
    
    [self callBackDidUpdate:manager.location];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self dealAuthorizationStatus:status];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"#location# didEnterRegion %@",region);
    [self callBackEnterRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"#location# didExitRegion %@",region);
    [self callBackLeaveRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"#location# didRangeBeacons %@",region);
    [self callBackBeaconRegion:region beacons:beacons];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"#location# rangingBeaconsDidFailForRegion %@",region);
    [self callBackBeaconRegionFail:error];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"#location# didDetermineState %@",region);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"#location# didUpdateHeading %@",newHeading);
    [self callBackUpdateHeading:newHeading];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    NSLog(@"#location# didVisit %@",visit);
}

@end

