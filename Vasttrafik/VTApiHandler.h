//
//  VTApiHandler.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSON.h"
#import "MPNAnnotation.h"
#import <CoreLocation/CoreLocation.h>

@interface VTApiHandler : NSObject {

}

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) upperLeft toCoordinates:(CLLocationCoordinate2D) lowerRight;
-(NSArray *)getPoiFromCoordinates:(CLLocationCoordinate2D) upperLeft toCoordinates:(CLLocationCoordinate2D) lowerRight;
- (id) objectWithUrl:(NSURL *)url;
- (NSString *)stringWithUrl:(NSURL *)url;

@end
