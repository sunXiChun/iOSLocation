//
//  ViewController.m
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import "ViewController.h"
#import "CoreBluetoothManager.h"
#import "LocationManager.h"
#import "GlobalToast.h"

@interface ViewController () <LocationDelegate>

@property (nonatomic,strong) CoreBluetoothManager *coreBluetoothManager;
@property (nonatomic,strong) LocationManager *locationManager;

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong) CLBeaconRegion *region;

@property (nonatomic,assign) BOOL isRecieve;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIView *arrow;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _region = [CoreBluetoothManager defaultRegion];
    _locationManager = [LocationManager locationManagerWithDelegate:self];
    _coreBluetoothManager = [[CoreBluetoothManager alloc] init];
    [_locationManager startOnceLocation];
    [_locationManager startMonitoringVisits];
    [_locationManager startUpdatingHeading];
}
- (IBAction)updating:(id)sender {
    [_locationManager startUpdatingLocation];
}

- (IBAction)region:(id)sender {
    [_locationManager startMonitoringForRegion:_coordinate radius:1];
}

- (IBAction)startBeacon:(id)sender {
    
    if ([_coreBluetoothManager isAdvertising]) {
        [_coreBluetoothManager stopBeaconSingal];
    }else {
        [_coreBluetoothManager startBeaconSingal:_region];
    }
}

- (IBAction)recieveBeacon:(id)sender {
    if (_isRecieve) {
        _isRecieve = NO;
        [_locationManager stopRangingBeacons:_region];
    }else {
        _isRecieve = YES;
        [_locationManager startRangingBeacons:_region];
    }
}

- (void)locationManager:(id)locationManager didUpdateLocation:(CLLocation *)location
{
    NSString *str = [NSString stringWithFormat:@"didUpdateLocation %f %f floor %ld speed %f",location.coordinate.longitude,location.coordinate.latitude,(long)location.floor.level,location.speed];
    [GlobalToast addText:str];
    _coordinate = location.coordinate;
    
    CGFloat headings = M_PI * location.course / 180.0f;
    _arrow.layer.transform = CATransform3DMakeRotation(headings, 0, 0, 1);
    
    _floorLabel.text = [NSString stringWithFormat:@"%ld层",(long)location.floor.level];
}

- (void)locationManager:(id)locationManager didEnterRegion:(CLRegion *)region
{
    [GlobalToast addText:@"locationManager didEnterRegion"];
}

- (void)locationManager:(id)locationManager didLeaveRegion:(CLRegion *)region
{
    [GlobalToast addText:@"locationManager didLeaveRegion"];
}

- (void)locationManager:(id)locationManager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSString *str = @"didRangeBeacons ";
    NSString *showText = @"收到的信号：\n";
    for (CLBeacon *b in beacons) {
        str = [str stringByAppendingString:[b.proximityUUID UUIDString]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[b.major stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[b.minor stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[@(b.accuracy) stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[@(b.proximity) stringValue]];
        str = [str stringByAppendingString:@" "];
        str = [str stringByAppendingString:[@(b.rssi) stringValue]];
        
        NSString *proximity;
        switch (b.proximity) {
            case CLProximityUnknown:
                proximity = @"Unknown";
                break;
            case CLProximityImmediate:
                proximity = @"Immediate";
                break;
            case CLProximityNear:
                proximity = @"Near";
                break;
            case CLProximityFar:
                proximity = @"Far";
                break;
            default:
                break;
        }
        
        showText = [showText stringByAppendingString:[NSString stringWithFormat:@"%@\nmajor:%@  minor:%@\n距离:%fm  信号:%ld\n 接近度:%@\n",[b.proximityUUID UUIDString],[b.major stringValue],[b.minor stringValue],b.accuracy,(long)b.rssi,proximity]];
        
        _showLabel.text = showText;
    }

    [GlobalToast addText:str];
}

- (void)locationManager:(id)locationManager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSString *str = [NSString stringWithFormat:@"rangingBeaconsDidFailForRegion %@",error];
    [GlobalToast addText:str];
}

- (void)locationManager:(id)locationManager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    _arrow.transform = CGAffineTransformMakeRotation(heading);
}

@end
