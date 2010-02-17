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

@interface VTApiHandler : NSObject {

}

-(void)runTest;

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates;
-(NSString *)getXMLfromCoordinates:(CLLocationCoordinate2D) centerCoordinates;
-(NSArray *)getForcastListForPoiId:(NSString *)poiId;
-(NSString *)getXMLfromPoiId:(NSString *)poiId;

- (NSString *)stringWithUrl:(NSURL *)url;

- (CLLocationCoordinate2D) rt90_to_GPS:(CLLocationCoordinate2D)gpsCoordinates;
- (CLLocationCoordinate2D) gps_to_RT90:(CLLocationCoordinate2D)gpsCoordinates;

@end
