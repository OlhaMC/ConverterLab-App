//
//  MapViewController.m
//  ConverterLab-App
//
//  Created by Admin on 21.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "MapViewController.h"
#import "BankObject.h"
#import "CityObject.h"
#import "RegionObject.h"

@interface MapViewController ()

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (assign, nonatomic) CLLocationCoordinate2D bankCoordinate;

@end

@implementation MapViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(zoomOutAction)];
    self.navigationItem.rightBarButtonItem = zoomButton;
    
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc]init];
    }
    
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *fullAddress = [self getFullAddressForGeocoding];
    
    [self geocodeBankAddress:fullAddress];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Geocoding
- (NSString*)getFullAddressForGeocoding {
    
    CityObject *city = self.bank.cityOfBank;
    NSString *cityName = city.name;
    RegionObject *region = self.bank.regionOfBank;
    NSString *regionName = region.name;
    
    NSString *fullAddress =
    [[NSString alloc] initWithFormat:@"%@ , %@ , %@",
     self.bank.address, cityName, regionName];
    
    return fullAddress;
}

- (void)geocodeBankAddress:(NSString*)bankAddress {
    
    [self.geocoder geocodeAddressString:bankAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinate = location.coordinate;
            self.bankCoordinate = coordinate;
//            NSLog(@"latitude-%f, longitude-%f", coordinate.latitude, coordinate.longitude);
//            
//            if ([placemark.areasOfInterest count] > 0) {
//                NSString *areasOfInterist = [placemark.areasOfInterest objectAtIndex:0];
//                NSLog(@"Areas of interest %ld - %@",
//                      placemark.areasOfInterest.count, areasOfInterist);
//            } else { NSLog(@"No areas of interest was found");}
        }
        if (error) {
            NSLog(@"Coordinates error - %@ %@", error, [error localizedDescription]);
        }
        
    }];
}

#pragma mark - MKMapViewDelegate
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.bankCoordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = self.bankCoordinate;
    point.title = self.bank.title;
    point.subtitle = [self getFullAddressForGeocoding];
    [self.mapView addAnnotation:point];
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)zoomOutAction {
    
    MKMapPoint center = MKMapPointForCoordinate(self.bankCoordinate);
    double delta = 20000;
    MKMapRect zoomRect = MKMapRectMake(center.x - delta, center.y - delta, delta*2, delta*2);

    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
    
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(self.mapView.region.span.latitudeDelta + 12, self.mapView.region.span.longitudeDelta + 12);
    
    
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(self.bankCoordinate, newSpan);
    [self.mapView setRegion:[self.mapView regionThatFits:newRegion] animated:YES];

}

@end
