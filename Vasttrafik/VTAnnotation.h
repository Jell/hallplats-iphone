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
	int poi_id;
	
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	NSString *mSubTitle;
	
	NSString *friendly_name;
	NSString *stop_name;
	NSString *county;
	
	int order;
	float distance;
	
	NSString *stop_id;
	NSString *stop_id_with_hash_key;
	NSString *shortcut;
	NSString *stop_type;

	NSArray *forecastList;
}


@property(retain) NSString *friendly_name;
@property(retain) NSString *stop_name;
@property(retain) NSString *county;

@property int order;
@property float distance;

@property(retain) NSString *stop_id;
@property(retain) NSString *stop_id_with_hash_key;
@property(retain) NSString *shortcut;
@property(retain) NSString *stop_type;

@property(retain) NSArray *forecastList;

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;
-(NSArray *)getLineList;

@end
