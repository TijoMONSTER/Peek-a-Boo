//
//  MapViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/18/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <UIAlertViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self zoomToAddress];
}

- (void)zoomToAddress
{
	CLGeocoder *geocoder = [CLGeocoder new];
	[geocoder geocodeAddressString:self.user.address
				 completionHandler:^(NSArray *placemarks, NSError *error) {
					 if (placemarks.count > 0) {

					 } else {
						 UIAlertView *alertView = [UIAlertView new];
						 alertView.message = [NSString stringWithFormat:@"No locations found for address %@", self.user.address];
						 alertView.delegate = self;
						 [alertView addButtonWithTitle:@"OK"];
						 [alertView show];
					 }
				 }];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
