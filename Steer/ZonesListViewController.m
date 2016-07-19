//
//  ZonesListViewController.m
//  Steer
//
//  Created by Enterpi iOS on 06/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import "ZonesListViewController.h"
#import <IndoorsSDK/IndoorsSDK.h>
#import <CoreLocation/CoreLocation.h>
#import <IndoorsSDK/IndoorsSurfaceBuilder.h>
#import "NavigationViewController.h"
#import <PulsingHalo/PulsingHaloLayer.h>
#import <QuartzCore/QuartzCore.h>

@interface ZonesListViewController () <IndoorsServiceDelegate, ISIndoorsSurfaceViewControllerDelegate, IndoorsLocationListener, RoutingDelegate, IndoorsSurfaceViewDelegate, UITableViewDelegate, ZoneListViewController>
{
    ISIndoorsSurfaceViewController *_indoorsSurfaceViewController;
}

// IBOutlets
@property (weak, nonatomic) IBOutlet UIView *currentLocationHolderView;
@property (weak, nonatomic) IBOutlet UITableView *zonesListTableView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIImageView *logoImgView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewVerticalSpacingConstraint;

@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;

// Global Variables

@property (strong, nonatomic) NSMutableArray *zonesDataArray;
@property (strong, nonatomic) ISImageAnnotationView *endLocPointerImgView;

@property(nonatomic, retain) ISIndoorsSurface *surfaceBuilder;
@property(nonatomic, retain) Indoors *indoors;
@property (strong, nonatomic) IDSBuilding *currentBuilding;
@property (strong, nonatomic) IDSCoordinate *currentLocation;
@property (strong, nonatomic) IDSZone *sourceZone;
@property (strong, nonatomic) NavigationViewController *nvc;


@end

@implementation ZonesListViewController

#pragma mark - View LifeCycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeObjects];
}

#pragma mark - ViewLifeCycle Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];

    _indoorsSurfaceViewController.delegate = self;
    _indoorsSurfaceViewController.surfaceView.delegate = self;
    [[Indoors instance] registerLocationListener:self];
    
}


- (void)viewDidAppear:(BOOL)animated
{

    [self addAnimation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)addAnimation
{
    if(!self.loadingView.isHidden)
    {
        PulsingHaloLayer *halo = [PulsingHaloLayer layer];
        halo.position = _logoImgView.center;
        halo.haloLayerNumber = 4;
        halo.radius = CGRectGetWidth(self.view.frame)/4;
        //    halo.backgroundColor = [UIColor colorWithRed:0.7
        //                                           green:0.9
        //                                            blue:0.3
        //                                           alpha:1.0].CGColor;

        [_loadingView.layer addSublayer:halo];
        [halo start];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    _indoorsSurfaceViewController.delegate = nil;
    _indoorsSurfaceViewController.surfaceView.delegate = nil;
    [[Indoors instance] registerLocationListener:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private API

- (void)initializeObjects {
    
    self.zonesDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.navigationController.navigationBarHidden = NO;
    
    _indoors = [[Indoors alloc] initWithLicenseKey:@"051be994-d233-4265-9f38-7c6f6f369032" andServiceDelegate:self]; // REPLACE WITH YOUR API KEY
    _indoorsSurfaceViewController = [[ISIndoorsSurfaceViewController alloc] init];
   
//    _indoorsSurfaceViewController.surfaceView.delegate = self;
    [self addSurfaceAsChildViewController];
    _surfaceBuilder = _indoorsSurfaceViewController.surfaceView;
    [self.surfaceBuilder setUserInteractionEnabled:NO];
    _indoorsSurfaceViewController.surfaceView.showsUserPosition = NO;

    [_indoorsSurfaceViewController loadBuildingWithBuildingId:793137053]; // REPLACE WITH YOUR BUILDING ID
    

    [_indoors enablePredefinedRouteSnapping];
    [_indoors setPredefinedRouteSnappingMaxDistance:5000];
    
    
    /// Dot on Rails #TMP
    _indoorsSurfaceViewController.surfaceView.dotOnRailsJumpingDistance = 10000;
    _indoorsSurfaceViewController.surfaceView.enableDotOnRails = YES;
    [_indoorsSurfaceViewController.surfaceView setZoneDisplayMode:IndoorsSurfaceZoneDisplayModeUserCurrentLocation];
    
    self.currentLocationHolderView.hidden = YES;
    self.zonesListTableView.hidden = YES;
    
}

- (void)buildingLoaded:(IDSBuilding *)building
{
    self.currentBuilding = building;
    [self getZones];


    // Overlay #TMP
    //    [self addImageOverlay];
}


- (void)addSurfaceAsChildViewController
{
    [self addChildViewController:_indoorsSurfaceViewController];
    _indoorsSurfaceViewController.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 180);
    [self.view addSubview:_indoorsSurfaceViewController.view];
    [_indoorsSurfaceViewController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:self.loadingView];
}

#pragma mark - ISIndoorsSurfaceViewControllerDelegate

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController isLoadingBuildingWithBuildingId:(NSUInteger)buildingId progress:(NSUInteger)progress
{
    NSLog(@"Building loading progress: %lu", (unsigned long)progress);
}

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFinishLoadingBuilding:(IDSBuilding *)building
{
    NSLog(@"Building loaded successfully!");
    [self buildingLoaded:building];
}

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFailLoadingBuildingWithBuildingId:(NSUInteger)buildingId error:(NSError *)error
{
    NSLog(@"Loading building failed with error: %@", error);
    
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}


#pragma mark - IndoorsLocationListener

- (void)positionUpdated:(IDSCoordinate *)userPosition
{
    self.currentLocation = userPosition;

    [self.surfaceBuilder setVisibleMapRect:CGRectMake(userPosition.x, userPosition.y, 1000, 1000) animated:YES];
}

- (void)zonesEntered:(NSArray *)zones {

    if ([zones count] > 0) {

        self.currentLocationHolderView.hidden = NO;
        self.zonesListTableView.hidden = NO;
        self.loadingView.hidden = YES;

        _sourceZone = (IDSZone *)[zones lastObject];

        CGRect startBounds = [[self.sourceZone polygonPath] bounds];
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:(startBounds.origin.x + startBounds.size.width/2) andY:(startBounds.origin.y + startBounds.size.height/2) andFloorLevel:0];

        IDSCoordinate *coordinate = [[IDSCoordinate alloc] initWithX:start.x andY:start.y andFloorLevel:0];

        [self.surfaceBuilder setVisibleMapRect:CGRectMake(coordinate.x, coordinate.y, 1000, 1000) animated:YES];

        if (self.endLocPointerImgView  != nil) {
            [_indoorsSurfaceViewController.surfaceView.mapScrollView removeAnnotation:self.endLocPointerImgView];
        }

        self.endLocPointerImgView = [[ISImageAnnotationView alloc] initWithCoordinate:start image:[UIImage imageNamed:@"Source"] position:ISAnnotationViewPositionTop];
        [_indoorsSurfaceViewController.surfaceView.mapScrollView addAnnotation:self.endLocPointerImgView];


        self.currentLocationLabel.text = [_sourceZone.name uppercaseString];


    }


/*
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Zones" message:[NSString stringWithFormat:@"%@, %@",zones, [zones valueForKey:@"name"]] preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];

    [controller addAction:okAction];

    [self presentViewController:controller animated:YES completion:nil]; */

}

#pragma mark - RouteDrawing methods

- (void)calculateRouteWithSelectedLocation:(IDSCoordinate *)location
{
    IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:self.currentLocation.x andY:self.currentLocation.y andFloorLevel:0];
    IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:location.x andY:location.y andFloorLevel:0];
    
    [[Indoors instance] routeFromLocation:start toLocation:end inBuilding:self.currentBuilding delegate:self];
}

// ...

#pragma mark - RoutingDelegate
- (void)setRoute:(NSArray *)path
{
    [self.surfaceBuilder showPathWithPoints:path color:[UIColor redColor] lineWidth:2];
    //    [_indoors enableRouteSnappingWithRoute:path];
}


#pragma mark - Indoors Surface View Delegate

- (void)indoorsSurface:(ISIndoorsSurface *)surfaceView userDidSelectLocation:(IDSCoordinate *)location
{
    NSLog(@"Selected location %@", location);
}

- (void)indoorsSurface:(ISIndoorsSurface *)surfaceView userDidTapLocation:(IDSCoordinate *)location
{
    
    [self calculateRouteWithSelectedLocation:location];
}



#pragma mark - IndoorsServiceDelegate

- (void)connected
{
    
}

- (void)onError:(IndoorsError *)indoorsError
{
    
}

- (void)locationAuthorizationStatusDidChange:(IDSLocationAuthorizationStatus)status
{
    
}

- (void)bluetoothStateDidChange:(IDSBluetoothState)bluetoothState
{
    
}


#pragma mark - ZONES
- (void) getZones
{
    for (IDSFloor *floor in self.currentBuilding.floors.allValues)
    {
        [_zonesDataArray addObjectsFromArray:floor.zones];
    }
    
    [self.zonesListTableView reloadData];

}

#pragma mark - DataSources

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.zonesDataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *zoneDataCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    IDSZone *zone = self.zonesDataArray[indexPath.row];
    zoneDataCell.textLabel.text = zone.name;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 44)];
    [headerView setBackgroundColor:[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0]];
    zoneDataCell.selectedBackgroundView = headerView;
    
    
    return zoneDataCell;
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 44)];
    [headerView setBackgroundColor:[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0]];
    UILabel *titleLabel = (UILabel *)[headerView viewWithTag:20];
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(tableView.frame) - 40, 44)];
        titleLabel.text = @"Where do you want to head to?";
        [titleLabel setFont:[UIFont fontWithName:@"ProximaNova-Semibold" size:18]];
        [titleLabel setTextColor:[UIColor colorWithRed:82.0/255.0 green:82.0/255.0 blue:82.0/255.0 alpha:1.0]];
        titleLabel.tag = 20;
        [headerView addSubview:titleLabel];
    }
    
    
  
    
    return headerView;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IDSZone *zone = self.zonesDataArray[indexPath.row];


    if (zone.zone_id != self.sourceZone.zone_id) {

        if (self.nvc == nil) {
            self.nvc = (NavigationViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"NavigationViewController"];
        }
        self.nvc.sourceZone = self.sourceZone;
        self.nvc.selectedZone = zone;
        self.nvc.zoneListDelegate = self;
        self.nvc.currentLocation = self.currentLocation;
        [self.navigationController pushViewController:self.nvc animated:YES];

    }else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"You are already in %@. Navigate to other location.", zone.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:okAction];
        [self presentViewController:controller animated:YES completion:nil];
    }


    

}

//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
//{
//    
//}
//
//-(id)presentationLayer
//{
//    CALayer *temp;
//    if ([[transMask animationKeys] count] > 0) {
//        temp = (CALayer *) [transMask presentationLayer];
//        [transMask setPosition:[temp position]];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
