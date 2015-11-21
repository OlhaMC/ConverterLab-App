//
//  MapViewController.h
//  ConverterLab-App
//
//  Created by Admin on 21.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class BankObject;

@interface MapViewController :UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) BankObject * bank;

@end
