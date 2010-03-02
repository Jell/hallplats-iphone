//
//  CoordinatesTests.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-09.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "AugmentedPoi.h"
#import "MPNAnnotation.h"
#import <CoreLocation/CoreLocation.h>

//#import "application_headers" as required


@interface CoordinatesTests : SenTestCase {
	AugmentedPoi *poiEquator;
	AugmentedPoi *poiNorthPole;
}

@end

@implementation CoordinatesTests


- (void) setUp {
	CLLocationCoordinate2D location = {0.0,0.0};
	CLLocationCoordinate2D origin = {10.0,0.0};
	poiEquator = [[AugmentedPoi alloc] initWithAnnotation:[[MPNAnnotation alloc] initWithCoordinate:location] fromOrigin:origin]; 
	STAssertNotNil(poiEquator, @"Could not create test subject.");
	
	location.latitude = 89.0;
	poiNorthPole = [[AugmentedPoi alloc] initWithAnnotation:[[MPNAnnotation alloc] initWithCoordinate:location] fromOrigin:origin];
}

-(void) testAngleConsistancy{
	float teta = poiEquator.azimuth;
	CLLocationCoordinate2D origin = {10.0,0.0};
	
	[poiEquator updateAngleFrom:origin];
	//STAssertTrue(FALSE, @"not correct angle");
	STAssertTrue(teta == poiEquator.azimuth, @"not consistant angle");
}

-(void) testAngleEquator {
	CLLocationCoordinate2D origin;
	float teta;
	
	origin.latitude = 10.0;
	origin.longitude = 0.0;
	[poiEquator updateAngleFrom:origin];
	teta = poiEquator.azimuth;
	STAssertTrue(abs(teta - 1.57) < 0.01, @"not correct angle: %f instead of PI/2", teta);
	
	origin.latitude = -10.0;
	origin.longitude = 0;
	[poiEquator updateAngleFrom:origin];
	teta = poiEquator.azimuth;
	STAssertTrue(abs(teta + 1.57) < 0.01, @"not correct angle: %f instead of -PI/2", teta);
	
	origin.latitude = 0.0;
	origin.longitude = 10.0;
	[poiEquator updateAngleFrom:origin];
	teta = poiEquator.azimuth;
	STAssertTrue(abs(teta) < 0.01, @"not correct angle: %f instead of 0.0", teta);
	
	origin.latitude = 0.0;
	origin.longitude = -10.0;
	[poiEquator updateAngleFrom:origin];
	teta = poiEquator.azimuth;
	STAssertTrue(abs(teta - 3.14159265) < 0.01 || abs(teta + 3.14159265) < 0.01, @"not correct angle: %f instead of PI", teta);
	//STAssertTrue(TRUE, @"It Works!");
	
	origin.latitude = 0.0;
	origin.longitude = 0.0;
	[poiEquator updateAngleFrom:origin];
	teta = poiEquator.azimuth;
	STAssertTrue(teta == 0.0, @"not correct angle: %f instead of 0.0", teta);
}

-(void) testAngleNorthPole {
	CLLocationCoordinate2D origin;
	float teta;
	
	origin.latitude = 90.0;
	origin.longitude = 0.0;
	[poiNorthPole updateAngleFrom:origin];
	teta = poiNorthPole.azimuth;
	STAssertTrue(abs(teta - 1.57) < 0.01, @"not correct angle: %f instead of PI/2", teta);
	
	origin.latitude = 80.0;
	origin.longitude = 0;
	[poiNorthPole updateAngleFrom:origin];
	teta = poiNorthPole.azimuth;
	STAssertTrue(abs(teta + 1.57) < 0.01, @"not correct angle: %f instead of -PI/2", teta);
	
	origin.latitude = 89.0;
	origin.longitude = 10.0;
	[poiNorthPole updateAngleFrom:origin];
	teta = poiNorthPole.azimuth;
	STAssertTrue(abs(teta) < 0.01, @"not correct angle: %f instead of 0.0", teta);
	
	origin.latitude = 89.0;
	origin.longitude = -10.0;
	[poiNorthPole updateAngleFrom:origin];
	teta = poiNorthPole.azimuth;
	STAssertTrue(abs(teta - 3.14159265) < 0.01 || abs(teta + 3.14159265) < 0.01, @"not correct angle: %f instead of PI", teta);
	//STAssertTrue(TRUE, @"It Works!");
	
	origin.latitude = 89.0;
	origin.longitude = 0.0;
	[poiNorthPole updateAngleFrom:origin];
	teta = poiNorthPole.azimuth;
	STAssertTrue(teta == 0.0, @"not correct angle: %f instead of 0.0", teta);
}

- (void) tearDown {
	[poiNorthPole release];
	[poiEquator release];
}

@end
