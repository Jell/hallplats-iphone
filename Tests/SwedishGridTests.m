//
//  SwedishGridTests.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 1

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
//#import "application_headers" as required
#import "VTApiHandler.h"
#import <CoreLocation/CoreLocation.h>

#define LAT_LNG_TOLERANCE		0.0000001
#define GRID_TOLERANCE			0.001

@interface SwedishGridTests : SenTestCase {
	VTApiHandler *mVThandler;
}


@end


@implementation SwedishGridTests

- (void) setUp {
	mVThandler = [[VTApiHandler alloc] init];
}

static const int testSize = 4;
static const float rt90x[] = {7453389.762, 7047738.415, 6671665.273, 6249111.351};
static const float rt90y[] = {1727060.905, 1522128.637, 1441843.186, 1380573.079};

static const float latitudes[] = {67 +  5/60.0 + 26.452769/3600,
									63 + 32/60.0 + 14.761735/3600,
									60 +  9/60.0 + 33.882413/3600,
									56 + 21/60.0 + 17.199245/3600};

static const float longitudes[] = {21 +  2/60.0 +  5.101575/3600,
									16 + 14/60.0 + 59.594626/3600,
									14 + 45/60.0 + 28.167152/3600,
									13 + 52/60.0 + 23.754022/3600};

-(void) testConversionR90{
	for (int i =0; i< testSize; i++) {
		CLLocationCoordinate2D input = {rt90x[i], rt90y[i]};
		CLLocationCoordinate2D output = [mVThandler rt90_to_GPS:input];
		
		STAssertTrue(abs(output.latitude - latitudes[i]) < LAT_LNG_TOLERANCE,
					 @"Conversion failed: \nOutput:\nLat: %f\nLon :%f\nExpected:\nLat: %f\nLon :%f",
					output.latitude, output.longitude, latitudes[i], longitudes[i]);
		STAssertTrue(abs(output.longitude - longitudes[i]) < LAT_LNG_TOLERANCE,
					 @"Conversion failed: \nOutput:\nLat: %f\nLon :%f\nExpected:\nLat: %f\nLon :%f",
					 output.latitude, output.longitude, latitudes[i], longitudes[i]);
	}
	
}

-(void) testConversionGPS{
	for (int i =0; i< testSize; i++) {
		CLLocationCoordinate2D input = {latitudes[i], longitudes[i]};
		CLLocationCoordinate2D output = [mVThandler gps_to_RT90:input];
		
		STAssertTrue(abs(output.latitude - rt90x[i]) < LAT_LNG_TOLERANCE,
					 @"Conversion failed: \nOutput:\nLat: %f\nLon :%f\nExpected:\nLat: %f\nLon :%f",
					 output.latitude, output.longitude, rt90x[i], rt90y[i]);
		STAssertTrue(abs(output.longitude - rt90y[i]) < LAT_LNG_TOLERANCE,
					 @"Conversion failed: \nOutput:\nLat: %f\nLon :%f\nExpected:\nLat: %f\nLon :%f",
					 output.latitude, output.longitude, rt90x[i], rt90y[i]);
	}
	
}

- (void) tearDown {
	[mVThandler release];
}

@end
