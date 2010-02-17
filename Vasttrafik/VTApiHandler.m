//
//  VTApiHandler.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTApiHandler.h"
#define VT_GETSTOPS_URL @"http://www.vasttrafik.se/External_Services/TravelPlanner.asmx/GetStopListBasedOnCoordinate?identifier=3e383cd8-30fa-47dc-8379-7d4295dc9db2&xCoord=6403382&yCoord=1272443"
#define VT_GETNEXT_URL @"http://www.vasttrafik.se/External_Services/NextTrip.asmx/GetForecast?identifier=3e383cd8-30fa-47dc-8379-7d4295dc9db2&stopId=00007172"

@implementation VTApiHandler

-(void)runTest
{
	CLLocationCoordinate2D coordinates = {0,0};
	
	NSArray *annotationList = [self getAnnotationsFromCoordinates:coordinates];

 	int i = 0;
	[annotationList release];
	
	
}

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates
{
	NSString *toBeParsed = [self getXMLfromCoordinates:centerCoordinates];

	NSMutableArray *annotationList = [[NSMutableArray alloc] init];
	
	NSMutableArray *itemList = (NSMutableArray *)[toBeParsed componentsSeparatedByString:@"&lt;/item&gt;"];
	
	if(itemList&&([itemList count] > 1)){
		[itemList removeLastObject];
		for(NSString *astring in itemList){
			
			NSArray *list1 = [astring componentsSeparatedByString:@"&lt;item"];
			NSString *cut1 = [list1 lastObject];
			
			NSArray *list2 = [cut1 componentsSeparatedByString:@"&gt;&lt;friendly_name&gt;&lt;![CDATA["];
			NSString *attributes = [list2 objectAtIndex:0];
			NSString *cut2 = [list2 lastObject];
			
			NSArray *list3 = [cut2 componentsSeparatedByString:@"]]&gt;&lt;/friendly_name&gt;&lt;stop_name&gt;&lt;![CDATA["];
			NSString *friendly_name = [list3 objectAtIndex:0];
			NSString *cut3 = [list3 lastObject];
			
			NSArray *list4 = [cut3 componentsSeparatedByString:@"]]&gt;&lt;/stop_name&gt;&lt;county&gt;&lt;![CDATA["];
			NSString *stop_name = [list4 objectAtIndex:0];
			NSString *cut4 = [list4 lastObject];
			
			NSArray *list5 = [cut4 componentsSeparatedByString:@"]]&gt;&lt;/county&gt;"];
			NSString *county = [list5 objectAtIndex:0];
			
			NSLog(friendly_name);
			NSLog(stop_name);
			NSLog(county);
			
			NSArray *attributesList = [attributes componentsSeparatedByString:@"\""];
			
			if([attributesList count]>=16){
				int order = [[attributesList objectAtIndex:1] intValue];
				NSString *stop_id = [attributesList objectAtIndex:3];
				NSString *stop_id_with_hash_key = [attributesList objectAtIndex:5];
				int distance  = [[attributesList objectAtIndex:7] intValue];
				NSString *shortcut = [attributesList objectAtIndex:9];
				NSString *stop_type = [attributesList objectAtIndex:11];
				int rt90_x = [[attributesList objectAtIndex:13] intValue];
				int rt90_y = [[attributesList objectAtIndex:15] intValue];
				
				NSLog(@"\nOrder: %d\nStop Id: %@\nStop Id with Hash: %@\nDistance: %dm\nShortcut: %@\nStop Type: %@\nrt90_x: %d\nrt90_y: %d\n", order, stop_id, stop_id_with_hash_key, distance, 
					  shortcut, stop_type, rt90_x, rt90_y);
				
				
				CLLocationCoordinate2D location = {(float)rt90_x, (float)rt90_y};
				VTAnnotation *anAnnotation = [[VTAnnotation alloc] initWithCoordinate:location];
				
				[anAnnotation setTitle:stop_name subtitle:[NSString stringWithFormat:@"%dm", distance]];
				
				anAnnotation.friendly_name = friendly_name;
				anAnnotation.stop_name = stop_name;
				anAnnotation.county = county;
				anAnnotation.order = order;
				anAnnotation.stop_id = stop_id;
				anAnnotation.stop_id_with_hash_key = stop_id_with_hash_key;
				anAnnotation.distance = distance;
				anAnnotation.shortcut = shortcut;
				anAnnotation.stop_type = stop_type;
				
				NSArray *forecastList = [self getForcastListForPoiId:@""];
				anAnnotation.forecastList = forecastList;
				
				[annotationList addObject:anAnnotation];
			}
		}
	}		
	
	NSArray *result = [[NSArray alloc] initWithArray:annotationList];
	[annotationList release];
	return result;
}


-(NSString *)getXMLfromCoordinates:(CLLocationCoordinate2D) centerCoordinates
{
	return [self stringWithUrl:[NSURL URLWithString:VT_GETSTOPS_URL]];;
}

-(NSArray *)getForcastListForPoiId:(NSString *)poiId
{
	NSString *toBeParsed = [self getXMLfromPoiId:poiId];
	NSLog(toBeParsed);
	NSMutableArray *forecastList = [[NSMutableArray alloc] init];
	
	NSMutableArray *itemList = (NSMutableArray *)[toBeParsed componentsSeparatedByString:@"&lt;/item&gt;"];
	if(itemList&&([itemList count] > 1)){
		[itemList removeLastObject];
		for(NSString *astring in itemList){
			
			NSArray *list1 = [astring componentsSeparatedByString:@"&lt;item"];
			NSString *cut1 = [list1 lastObject];
			
			NSArray *list2 = [cut1 componentsSeparatedByString:@"&gt;&lt;destination&gt;&lt;![CDATA["];
			NSString *attributes = [list2 objectAtIndex:0];
			NSString *cut2 = [list2 lastObject];
			
			NSArray *list3 = [cut2 componentsSeparatedByString:@"]]&gt;&lt;/destination&gt;"];
			NSString *destination = [list3 objectAtIndex:0];
			
			NSArray *attributesList = [attributes componentsSeparatedByString:@"\""];
			
			if([attributesList count] >= 24){
				VTForecast *aForecast = [[[VTForecast alloc] init] retain];
				
				NSString *lineNumber = [attributesList objectAtIndex:7];
				
				/*
				UIColor *foregroundColor = [attributesList objectAtIndex:9];
				UIColor *backgroundColor = [attributesList objectAtIndex:11];
				*/
				
				UIColor *foregroundColor = [UIColor whiteColor];
				UIColor *backgroundColor = [UIColor blueColor];
				
				NSString *imageType = [attributesList objectAtIndex:3];
				
				NSString *nastaTime = [attributesList objectAtIndex:13];
				NSString *darefterTime = [attributesList objectAtIndex:21];
				
				BOOL nastaHandicap = ![(NSString *)[attributesList objectAtIndex:15] isEqual:@""];
				BOOL darefterHandicap = ![(NSString *)[attributesList objectAtIndex:23] isEqual:@""];
				
				aForecast.lineNumber = lineNumber;
				aForecast.foregroundColor = foregroundColor;
				aForecast.backgroundColor = backgroundColor;
				aForecast.imageType = imageType;
				aForecast.destination = destination;
				aForecast.nastaTime = nastaTime;
				aForecast.nastaHandicap = nastaHandicap;
				aForecast.darefterTime = darefterTime;
				aForecast.darefterHandicap = darefterHandicap;
				
				[forecastList addObject:aForecast];
			}
		}
	}
	
	NSArray *result = [[NSArray alloc] initWithArray:forecastList];
	[forecastList release];
	return result;
}

-(NSString *)getXMLfromPoiId:(NSString *)poiId{
	return [self stringWithUrl:[NSURL URLWithString:VT_GETNEXT_URL]];
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}


- (CLLocationCoordinate2D) rt90_to_GPS:(CLLocationCoordinate2D)gpsCoordinates{
	CLLocationCoordinate2D result = {0,0};
	return result;
}
- (CLLocationCoordinate2D) gps_to_RT90:(CLLocationCoordinate2D)gpsCoordinates{
	CLLocationCoordinate2D result = {0,0};
	return result;
}

@end
