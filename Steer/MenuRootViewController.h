//
//  MenuRootViewController.h
//  Steer
//
//  Created by Enterpi iOS on 13/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import <RESideMenu/RESideMenu.h>

@interface MenuRootViewController : RESideMenu <RESideMenuDelegate>

@property (strong, readwrite, nonatomic) UIViewController *zonesListViewController;

@end
