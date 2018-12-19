//
//  LocationCenter.m
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import "LocationCenter.h"
#import <UIKit/UIKit.h>

@interface LocationCenter () <LocationDelegate>

@property (nonatomic,strong,readwrite) LocationManager * locationManager;

@end

@implementation LocationCenter

+ (instancetype)defaultCenter
{
    static LocationCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[LocationCenter alloc] init];
        center.locationManager = [LocationManager locationManagerWithDelegate:center];
        [center addNotification];
    });
    
    return center;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)willEnterForeground
{
    [self.locationManager stopMonitoringLocation];
}

- (void)didEnterBackground
{
    [self.locationManager startMonitoringLocation];
}

- (void)willTerminate
{
    [self.locationManager startMonitoringLocation];
}

@end
