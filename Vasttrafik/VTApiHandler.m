//
//  VTApiHandler.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTApiHandler.h"
#define VT_GETSTOPS_URL @"http://www.vasttrafik.se/External_Services/TravelPlanner.asmx/GetStopListBasedOnCoordinate?identifier=3e383cd8-30fa-47dc-8379-7d4295dc9db2&xCoord=%d&yCoord=%d"
#define VT_GETNEXT_URL @"http://www.vasttrafik.se/External_Services/NextTrip.asmx/GetForecast?identifier=3e383cd8-30fa-47dc-8379-7d4295dc9db2&stopId=%@"

@implementation VTApiHandler

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates
{
	NSString *toBeParsed = [self getXMLfromCoordinates:centerCoordinates];
	if([toBeParsed isEqual:@""]){
		return nil;
	}
	
	NSMutableArray *annotationList = [[NSMutableArray alloc] init];
	
	NSMutableArray *itemList = (NSMutableArray *)[toBeParsed componentsSeparatedByString:@"&lt;/item&gt;"];
	
	if(itemList&&([itemList count] > 1)){
		[itemList removeLastObject];
		int itemNumber = 0;
		for(NSString *astring in itemList){
			if(itemNumber <10){
				itemNumber++;
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
				
				/*
				NSLog(friendly_name);
				NSLog(stop_name);
				NSLog(county);
				*/
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
					
					/*
					NSLog(@"\nOrder: %d\nStop Id: %@\nStop Id with Hash: %@\nDistance: %dm\nShortcut: %@\nStop Type: %@\nrt90_x: %d\nrt90_y: %d\n", order, stop_id, stop_id_with_hash_key, distance, 
						  shortcut, stop_type, rt90_x, rt90_y);
					*/
					CLLocationCoordinate2D location = {(float)rt90_x, (float)rt90_y};
					VTAnnotation *anAnnotation = [[VTAnnotation alloc] initWithCoordinate:[self rt90_to_GPS:location]];
					
					[anAnnotation setTitle:stop_name subtitle:[[NSString stringWithFormat:@"%dm", distance] retain]];
					
					anAnnotation.friendly_name = friendly_name;
					anAnnotation.stop_name = stop_name;
					anAnnotation.county = county;
					anAnnotation.order = order;
					anAnnotation.stop_id = stop_id;
					anAnnotation.stop_id_with_hash_key = stop_id_with_hash_key;
					anAnnotation.distance = distance;
					anAnnotation.shortcut = shortcut;
					anAnnotation.stop_type = stop_type;
					
					NSArray *forecastList = [self getForcastListForPoiId:stop_id];
					anAnnotation.forecastList = forecastList;
					
					[annotationList addObject:anAnnotation];
				}
			}
		}
	}		
	
	NSArray *result = [[NSArray alloc] initWithArray:annotationList];
	[annotationList release];
	return result;
}


-(NSString *)getXMLfromCoordinates:(CLLocationCoordinate2D) centerCoordinates
{
	CLLocationCoordinate2D centerRT90 = [self gps_to_RT90:centerCoordinates];
	int x = centerRT90.latitude;
	int y = centerRT90.longitude;
	for(int i = 0; i<5; i++){
		NSString *result = [self stringWithUrl:[NSURL URLWithString:[NSString stringWithFormat: VT_GETSTOPS_URL, x, y]]];
		if([result length]>14){
			NSString *test = [result substringToIndex:14];
			if(![test isEqual:@"<!DOCTYPE html"]){
				return result;
			}
		}
	}
	
	return @"";

}

-(NSArray *)getForcastListForPoiId:(NSString *)poiId
{
	NSString *toBeParsed = [self getXMLfromPoiId:poiId];
	/*NSLog(toBeParsed);*/
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
				
				UIColor *foregroundColor = [self stringToColor:[attributesList objectAtIndex:9]];
				UIColor *backgroundColor = [self stringToColor:[attributesList objectAtIndex:11]];
				
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
	[forecastList sortUsingSelector:@selector(compareWith:)];
	NSArray *result = [[NSArray alloc] initWithArray:forecastList];
	[forecastList release];
	return result;
}

-(NSString *)getXMLfromPoiId:(NSString *)poiId{
	
	for(int i = 0; i<3; i++){
		NSString *result = [self stringWithUrl:[NSURL URLWithString:[NSString stringWithFormat:VT_GETNEXT_URL, poiId]]];
		if([result length]>14){
			NSString *test = [result substringToIndex:14];
			if(![test isEqual:@"<!DOCTYPE html"]){
				return result;
			}
		}
	}
	return @"";
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											timeoutInterval:2];
	for(int i = 0; i<3;i++){
		// Fetch the JSON response
		NSData *urlData;
		NSURLResponse *response;
		NSError *error;
		
		// Make synchronous request
		urlData = [NSURLConnection sendSynchronousRequest:urlRequest
										returningResponse:&response
													error:&error];
		// Construct a String around the Data from the response
		if(!error){
			return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
		}
	}
	return @"";
}


- (CLLocationCoordinate2D) rt90_to_GPS:(CLLocationCoordinate2D)gpsCoordinates{
	
	float x = gpsCoordinates.latitude;
	float y = gpsCoordinates.longitude;
// Prepare ellipsoid-based stuff.
	float e2 = flattening * (2.0 - flattening);
    float n = flattening / (2.0 - flattening);
    float a_roof = axis / (1.0 + n) * (1.0 + n*n/4.0 + n*n*n*n/64.0);
    float delta1 = n/2.0 - 2.0*n*n/3.0 + 37.0*n*n*n/96.0 - n*n*n*n/360.0;
    float delta2 = n*n/48.0 + n*n*n/15.0 - 437.0*n*n*n*n/1440.0;
    float delta3 = 17.0*n*n*n/480.0 - 37*n*n*n*n/840.0  ;
    float delta4 = 4397.0*n*n*n*n/161280.0;
	
    float astar = e2 + e2*e2 + e2*e2*e2 + e2*e2*e2*e2;
    float bstar = -(7.0*e2*e2 + 17.0*e2*e2*e2 + 30.0*e2*e2*e2*e2) / 6.0;
    float cstar = (224.0*e2*e2*e2 + 889.0*e2*e2*e2*e2) / 120.0;
    float dstar = -(4279.0*e2*e2*e2*e2) / 1260.0;
	
// Convert.
    float lambda_zero = central_meridian * deg_to_rad;
    float xi = (x - false_northing) / (scale * a_roof);
    float eta = (y - false_easting) / (scale * a_roof);
    float xi_prim = xi - 
					delta1*sin(2.0*xi) * cosh(2.0*eta) - 
					delta2*sin(4.0*xi) * cosh(4.0*eta) - 
					delta3*sin(6.0*xi) * cosh(6.0*eta) - 
					delta4*sin(8.0*xi) * cosh(8.0*eta);
	
    float eta_prim = eta - 
					delta1*cos(2.0*xi) * sinh(2.0*eta) - 
					delta2*cos(4.0*xi) * sinh(4.0*eta) - 
					delta3*cos(6.0*xi) * sinh(6.0*eta) - 
					delta4*cos(8.0*xi) * sinh(8.0*eta);
	
    float phi_star = asin(sin(xi_prim) / cosh(eta_prim));
	
    float delta_lambda = atan(sinh(eta_prim) / cos(xi_prim));
    float lng_radian = lambda_zero + delta_lambda ;
    float lat_radian = phi_star + sin(phi_star) * cos(phi_star) *
								(astar + 
								 bstar*(pow(sin(phi_star), 2)) + 
								 cstar*(pow(sin(phi_star), 4)) + 
								 dstar*(pow(sin(phi_star), 6)));

	CLLocationCoordinate2D result = {lat_radian * 180.0 / M_PI,lng_radian * 180.0 / M_PI};
	return result;
}

- (CLLocationCoordinate2D) gps_to_RT90:(CLLocationCoordinate2D)gpsCoordinates{

	float latitude = gpsCoordinates.latitude;
	float longitude = gpsCoordinates.longitude;
// Prepare ellipsoid-based stuff.
    float e2 = flattening * (2.0 - flattening);
    float n = flattening / (2.0 - flattening);
    float a_roof = axis / (1.0 + n) * (1.0 + n*n/4.0 + n*n*n*n/64.0);
    float a = e2;
    float b = (5.0*e2*e2 - e2*e2*e2) / 6.0;
    float c = (104.0*e2*e2*e2 - 45.0*e2*e2*e2*e2) / 120.0;
    float d = (1237.0*e2*e2*e2*e2) / 1260.0;
    float beta1 = n/2.0 - 2.0*n*n/3.0 + 5.0*n*n*n/16.0 + 41.0*n*n*n*n/180.0;
    float beta2 = 13.0*n*n/48.0 - 3.0*n*n*n/5.0 + 557.0*n*n*n*n/1440.0;
    float beta3 = 61.0*n*n*n/240.0 - 103.0*n*n*n*n/140.0;
    float beta4 = 49561.0*n*n*n*n/161280.0;
	
// Convert.
    float phi = latitude * deg_to_rad;
    float lambda = longitude * deg_to_rad;
    float lambda_zero = central_meridian * deg_to_rad;
	
    float phi_star = phi - sin(phi) * cos(phi) * (a + 
												  b*(pow(sin(phi), 2)) + 
												  c*(pow(sin(phi), 4)) + 
												  d*(pow(sin(phi), 6)));
	
    float delta_lambda = lambda - lambda_zero;
    float xi_prim = atan(tan(phi_star) / cos(delta_lambda));
    float eta_prim = atanh(cos(phi_star) * sin(delta_lambda));
	
    float x = scale * a_roof * (xi_prim + 
									 beta1 * sin(2.0*xi_prim) * cosh(2.0*eta_prim) +
									 beta2 * sin(4.0*xi_prim) * cosh(4.0*eta_prim) +
									 beta3 * sin(6.0*xi_prim) * cosh(6.0*eta_prim) +
									 beta4 * sin(8.0*xi_prim) * cosh(8.0*eta_prim)) +
										false_northing;
	
    float y = scale * a_roof * (eta_prim +
						   beta1 * cos(2.0*xi_prim) * sinh(2.0*eta_prim) +
						   beta2 * cos(4.0*xi_prim) * sinh(4.0*eta_prim) +
						   beta3 * cos(6.0*xi_prim) * sinh(6.0*eta_prim) +
						   beta4 * cos(8.0*xi_prim) * sinh(8.0*eta_prim)) +
							false_easting;

	CLLocationCoordinate2D result = {round(x * 1000.0) / 1000.0, round(y * 1000.0) / 1000.0};
	return result;
}

-(int)charHexToInt:(unichar)charValue{
	int result = charValue - 48;
	if(result>9){
		result -= 7;
	}
	if(result<0 || result>15){
		return 0;
	}else{
		return result;
	}
}

-(UIColor *)stringToColor:(NSString *)stringColor{
	NSString *capitalLetters = [stringColor uppercaseString];
	float red = [self charHexToInt:[capitalLetters characterAtIndex:1]]*16 +
				[self charHexToInt:[capitalLetters characterAtIndex:2]];
	float green = [self charHexToInt:[capitalLetters characterAtIndex:3]]*16 +
				[self charHexToInt:[capitalLetters characterAtIndex:4]];
	float blue = [self charHexToInt:[capitalLetters characterAtIndex:5]]*16 +
				[self charHexToInt:[capitalLetters characterAtIndex:6]];
	
	return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}




@end
