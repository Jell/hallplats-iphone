//
//  VTApiHandler.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "VTAnnotation.h"
#import "VTForecast.h"
#import <math.h>

@interface VTApiHandler : NSObject {

}

static const float axis = 6378137.0;
static const float flattening = 1.0 / 298.257222101;
static const float central_meridian = 15.806284529;
static const float lat_of_origin = 0.0;
static const float scale = 1.00000561024;
static const float false_northing = -667.711;
static const float false_easting = 1500064.274;
static const float deg_to_rad =  M_PI / 180.0;

-(void)runTest;

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates;
-(NSString *)getXMLfromCoordinates:(CLLocationCoordinate2D) centerCoordinates;
-(NSArray *)getForcastListForPoiId:(NSString *)poiId;
-(NSString *)getXMLfromPoiId:(NSString *)poiId;

- (NSString *)stringWithUrl:(NSURL *)url;

- (CLLocationCoordinate2D) rt90_to_GPS:(CLLocationCoordinate2D)gpsCoordinates;
- (CLLocationCoordinate2D) gps_to_RT90:(CLLocationCoordinate2D)gpsCoordinates;

@end
