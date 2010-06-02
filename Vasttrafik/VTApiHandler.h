/**
 Responsible for API requests to the Västtrafik webservices
 */

//
//  VTApiHandler.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#import "MPNAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "VTAnnotation.h"
#import "VTForecast.h"
#import <math.h>
#import "JSON.h"

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

/** Fetch a VTAnnotation list from the given origin */
-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates;

/** Get the content of the given URL */
- (NSString *)stringWithUrl:(NSURL *)url;

- (id) objectWithUrl:(NSURL *)url;

/** Convert RT90 coordinates to WGS84 coordinate system */
- (CLLocationCoordinate2D) rt90_to_GPS:(CLLocationCoordinate2D)gpsCoordinates;

/** Convert WGS84 coordinates to RT90 coordinate system */
- (CLLocationCoordinate2D) gps_to_RT90:(CLLocationCoordinate2D)gpsCoordinates;

/** Retrieve the decimal value from a hexadecimal value represented by a single Char
 @param charValue should be 1~9 or A~F */
int charHexToInt(unichar charValue);

/** Convert a String to a UIColor
 @param stringColor should be \#RRGGBB */
UIColor * stringToColor(NSString *stringColor);

@end
