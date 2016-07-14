//
//  NavigationViewController.m
//  Steer
//
//  Created by Enterpi iOS on 08/07/16.
//  Copyright © 2016 Enterpi iOS. All rights reserved.
//

#import "NavigationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <IndoorsSDK/IndoorsSurfaceBuilder.h>
#import <PulsingHalo/PulsingHaloLayer.h>

@interface NavigationViewController () <IndoorsServiceDelegate, ISIndoorsSurfaceViewControllerDelegate, IndoorsLocationListener, RoutingDelegate, IndoorsSurfaceViewDelegate, UITableViewDelegate>
{
    ISIndoorsSurfaceViewController *_indoorsSurfaceViewController;
}

@property(nonatomic, retain) ISIndoorsSurface *surfaceBuilder;
@property (strong, nonatomic) IDSBuilding *currentBuilding;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImgView;

@property (strong, nonatomic) ISImageAnnotationView *startLocPointerImgView;
@property (strong, nonatomic) ISImageAnnotationView *endLocPointerImgView;

@property (weak, nonatomic) IBOutlet UIButton *navElseButton;
@property (strong, nonatomic) NSMutableArray *zonesDataArray;
@property (assign) BOOL isBuildingLoaded;

@end

@implementation NavigationViewController

#pragma mark - View LifeCycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeObjects];

}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
//
//    IDSBuildingManager *buildingManager = [[IDSBuildingManager alloc] init];
//    [buildingManager loadBuildingWithId:793137053 progress:^(double progress, NSUInteger currentStep, NSUInteger totalSteps, NSString *phase)
//    {
//        NSLog(@"Progress: %f", progress);
//    } completion:^(IDSBuilding *building, NSError *error)
//    {
//        if (error)
//        {
//            NSLog(@"An error occured: %@ Reason: %@", error.localizedDescription, error.localizedFailureReason);
//            return;
//        }
//
//        [_indoorsSurfaceViewController.surfaceView setBuildingForSurface:building];
//
//    }];

    _indoorsSurfaceViewController.delegate = self;
    _indoorsSurfaceViewController.surfaceView.delegate = self;
    [[Indoors instance] registerLocationListener:self];

    if (self.isBuildingLoaded) {
        [self calculateRouteWithSelectedZone];
    }


}

- (void)viewDidAppear:(BOOL)animated {
    
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
    
    
    self.navElseButton.layer.borderColor = [[UIColor colorWithRed:53.0/255.0 green:97.0/255.0 blue:143.0/255.0 alpha:1.0] CGColor];
    self.navElseButton.layer.borderWidth = 2.0;
    self.navElseButton.layer.cornerRadius = 2.0;
    
    self.navigationController.navigationBarHidden = NO;

    _indoorsSurfaceViewController = [[ISIndoorsSurfaceViewController alloc] init];
  
    [self addSurfaceAsChildViewController];
    _surfaceBuilder = _indoorsSurfaceViewController.surfaceView;
    _indoorsSurfaceViewController.surfaceView.showsUserPosition = YES;

    self.isBuildingLoaded = NO;
    [_indoorsSurfaceViewController loadBuildingWithBuildingId:793137053]; // REPLACE WITH YOUR BUILDING ID


    [[Indoors instance] enablePredefinedRouteSnapping];
    [[Indoors instance] setPredefinedRouteSnappingMaxDistance:1000]; // 1000 to 20000

    [[Indoors instance] setEnableStabilisationFilter:YES];
    [[Indoors instance] setStabilisationFilterTime:4000]; // 4000 to 20000

    /// Dot on Rails #TMP
    _indoorsSurfaceViewController.surfaceView.dotOnRailsJumpingDistance = 1000; // 1000 to 30000
    _indoorsSurfaceViewController.surfaceView.enableDotOnRails = YES;
    [_indoorsSurfaceViewController.surfaceView setZoneDisplayMode:IndoorsSurfaceZoneDisplayModeUserCurrentLocation];

}

- (void)buildingLoaded:(IDSBuilding *)building
{
    self.loadingView.hidden = YES;
    self.currentBuilding = building;
    self.isBuildingLoaded = YES;
    [self calculateRouteWithSelectedZone];

    // Overlay #TMP
    //    [self addImageOverlay];
}


- (void)addSurfaceAsChildViewController
{
    [self addChildViewController:_indoorsSurfaceViewController];
    _indoorsSurfaceViewController.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 150);
    [self.view addSubview:_indoorsSurfaceViewController.view];
    [_indoorsSurfaceViewController didMoveToParentViewController:self];
}

#pragma mark - ISIndoorsSurfaceViewControllerDelegate

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController isLoadingBuildingWithBuildingId:(NSUInteger)buildingId progress:(NSUInteger)progress
{
//    NSLog(@"Building loading progress: %lu", (unsigned long)progress);
}

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFinishLoadingBuilding:(IDSBuilding *)building
{
//    NSLog(@"Building loaded successfully!");
    [self buildingLoaded:building];
}

- (void)indoorsSurfaceViewController:(ISIndoorsSurfaceViewController *)indoorsSurfaceViewController didFailLoadingBuildingWithBuildingId:(NSUInteger)buildingId error:(NSError *)error
{
//    NSLog(@"Loading building failed with error: %@", error);

    [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
}


#pragma mark - IndoorsLocationListener

- (void)positionUpdated:(IDSCoordinate *)userPosition
{
    self.currentLocation = userPosition;
}

#pragma mark - RouteDrawing methods

- (void)calculateRouteWithSelectedZone
{
    
    CGRect startBounds = [[self.sourceZone polygonPath] bounds];
    CGRect endBounds = [[self.selectedZone polygonPath] bounds];
    
    
        IDSCoordinate* start = [[IDSCoordinate alloc] initWithX:(startBounds.origin.x + startBounds.size.width/2) andY:(startBounds.origin.y + startBounds.size.height/2) andFloorLevel:0];
        IDSCoordinate* end = [[IDSCoordinate alloc] initWithX:(endBounds.origin.x + endBounds.size.width/2) andY:(endBounds.origin.y + endBounds.size.height/2) andFloorLevel:0];
    
    
    if (self.startLocPointerImgView == nil) {
        self.startLocPointerImgView = [[ISImageAnnotationView alloc] initWithCoordinate:(self.currentLocation == nil)?start:self.currentLocation image:[UIImage imageNamed:@"Source"] position:ISAnnotationViewPositionTop];
    }else {
        [self.startLocPointerImgView setCoordinate:(self.currentLocation == nil)?start:self.currentLocation animated:YES];
    }
    
    if (self.endLocPointerImgView == nil) {
        self.endLocPointerImgView = [[ISImageAnnotationView alloc] initWithCoordinate:end image:[UIImage imageNamed:@"Destination"] position:ISAnnotationViewPositionTop];
    }else {
        [self.endLocPointerImgView setCoordinate:end animated:YES];
    }
    
    
    [[Indoors instance] routeFromLocation:(self.currentLocation == nil)?start:self.currentLocation toLocation:end inBuilding:self.currentBuilding delegate:self];
}

// ...

#pragma mark - RoutingDelegate
- (void)setRoute:(NSArray *)path
{
    
    if ([path count] == 0) {
        [self calculateRouteWithSelectedZone];
    }else {
        [_indoorsSurfaceViewController.surfaceView.mapScrollView addAnnotation:self.startLocPointerImgView];
        [_indoorsSurfaceViewController.surfaceView.mapScrollView addAnnotation:self.endLocPointerImgView];

        [self.surfaceBuilder showPathWithPoints:path color:[UIColor colorWithRed:96.0/255.0 green:209.0/255.0 blue:233.0/255.0 alpha:1.0] lineWidth:3];

    }
}


#pragma mark - Indoors Surface View Delegate

- (void)indoorsSurface:(ISIndoorsSurface *)surfaceView userDidSelectLocation:(IDSCoordinate *)location
{
    NSLog(@"Selected location %@", location);
}

- (void)indoorsSurface:(ISIndoorsSurface *)surfaceView userDidTapLocation:(IDSCoordinate *)location
{
    
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

/*
#pragma mark - ZONES
- (void) getZones
{
    for (IDSFloor *floor in self.currentBuilding.floors.allValues)
    {
        [_zonesDataArray addObjectsFromArray:floor.zones];
    }
        
    for (IDSZone *tempZne in _zonesDataArray)
    {
        NSLog(@"zoneeee name::: %@", tempZne.name);
        
        
        
        
        
        //        NSLog(@"zoneeee floor_id::: %lu", (unsigned long)tempZne.floor_id);
        //        NSLog(@"zoneeee zoneDescription::: %@", tempZne.zoneDescription);
        for (IDSZonePoint *tempZnePoint in tempZne.points)
        {
            NSLog(@"IDSZonePoint x -- %d and y -- %d  sortOrder:%d -- zonepoint_id:  %d", tempZnePoint.x, tempZnePoint.y, tempZnePoint.sortOrder, tempZnePoint.zonepoint_id);
        }
        //        NSLog(@"zoneeee points::: %ld", tempZne.zone_id);
        //        NSLog(@"zoneeee speed %lu:: (unsigned long)%@", tempZne.speed);
    }
}
*/


#pragma mark - IBAction Methods

- (IBAction)backToZoneSelection:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
//    [_indoorsSurfaceViewController.building unloadBuilding:_currentBuilding];
//     IDSBuildingManager *buildingManager = [[IDSBuildingManager alloc] init];
//    [buildingManager unloadBuilding:_currentBuilding];
//    _indoorsSurfaceViewController = nil;
//    _surfaceBuilder = nil;
//    _currentBuilding= nil;
//    _currentLocation = nil;
//    _startLocPointerImgView = nil;
//    _endLocPointerImgView = nil;


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
