//
//  LocationCenter.h
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"

@interface LocationCenter : NSObject

@property (nonatomic,strong,readonly) LocationManager * locationManager;

+ (instancetype)defaultCenter;

@end
