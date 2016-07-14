//
//  NavigationViewController.h
//  Steer
//
//  Created by Enterpi iOS on 08/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IndoorsSDK/IndoorsSDK.h>
#import "ZonesListViewController.h"

@interface NavigationViewController : UIViewController

@property (strong, nonatomic) IDSZone *sourceZone;
@property (strong, nonatomic) IDSZone *selectedZone;
@property (strong, nonatomic) IDSCoordinate *currentLocation;
@property (assign, nonatomic) id <ZoneListViewController> zoneListDelegate;

@end
