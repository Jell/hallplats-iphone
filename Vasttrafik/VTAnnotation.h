/**
 Container for Västtrafik stop information
 */

//
//  VTAnnotation.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "VTLineInfo.h"
#import "VTForecast.h"

@interface VTAnnotation : NSObject  <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	NSString *mSubTitle;
	
	NSString *stop_name;
	
	float distance;
	
	NSString *stop_id;
	NSString *stop_type;

	NSArray *forecastList;
}

@property(nonatomic, retain) NSString *stop_name;
@property(nonatomic) float distance;
@property(nonatomic, retain) NSString *stop_id;
@property(nonatomic, retain) NSString *stop_type;
@property(nonatomic, retain) NSArray *forecastList;

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;
-(void)setSubtitle:(NSString *)subtitle;
-(NSArray *)getLineList;

/** Updates Distance */
-(void)updateDistanceFrom:(CLLocationCoordinate2D)origin;

@end
