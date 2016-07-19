//
//  LeftMenuViewController.m
//  Steer
//
//  Created by Enterpi iOS on 13/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import "LeftMenuViewController.h"
#import <RESideMenu/RESideMenu.h>
#import <UIViewController+RESideMenu.h>

@interface LeftMenuViewController () <UITableViewDelegate, UITableViewDataSource, RESideMenuDelegate>

@property (weak, nonatomic) IBOutlet UITableView *leftMenuTableView;
@property (strong, nonatomic) NSArray *menuNamesArray;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeObjects];
    // Do any additional setup after loading the view.
    CGRect tableFrame = self.leftMenuTableView.frame;
    self.leftMenuTableView.translatesAutoresizingMaskIntoConstraints = YES;

    [self.leftMenuTableView setBackgroundColor:[UIColor clearColor]];

    int yAxis_Center = ((self.view.frame.size.height)-(_menuNamesArray.count*60))/2;
       self.leftMenuTableView.frame = CGRectMake(self.leftMenuTableView.frame.origin.x, yAxis_Center, tableFrame.size.width,  _menuNamesArray.count*60);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private API

- (void)initializeObjects {
    
//    self.menuNamesArray = [[NSArray alloc] initWithObjects:@"My Location", @"How it works?", @"About us", @"Credits", nil];
    self.menuNamesArray = [[NSArray alloc] initWithObjects:@"MY LOCATION", @"HOW IT WORKS?", @"ABOUT US", @"CREDITS", nil];

}


#pragma mark - DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuNamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *leftMenuCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    leftMenuCell.textLabel.text = self.menuNamesArray[indexPath.row];

    return leftMenuCell;
}

#pragma mark - Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0: {

            [self.sideMenuViewController setContentViewController:self.sideMenuViewController.zonesListViewController
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
            
        case 1:
        case 2: {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Work in progress" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.sideMenuViewController hideMenuViewController];

            }];
            
            [controller addAction:okAction];
            
            [self presentViewController:controller animated:YES completion:nil];
            
        }
            break;
            
        case 3: {
            [self.sideMenuViewController setContentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CreditsNavigationController"]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
        }
            break;
            
        default:
            break;
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
