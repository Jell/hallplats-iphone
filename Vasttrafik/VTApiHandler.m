//
//  VTApiHandler.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTApiHandler.h"

#define HALLPLATS_URL			@"http://hallplats.mittpostnummer.se/index.yaws?lat=%f&lng=%f"

#define VT_IDENTIFIER			@"3e383cd8-30fa-47dc-8379-7d4295dc9db2"
#define VT_GETSTOPS_URL			@"http://www.vasttrafik.se/External_Services/TravelPlanner.asmx/GetStopListBasedOnCoordinate?identifier=%@&xCoord=%d&yCoord=%d"
#define VT_GETNEXT_URL			@"http://www.vasttrafik.se/External_Services/NextTrip.asmx/GetForecast?identifier=%@&stopId=%@"

@implementation VTApiHandler

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) centerCoordinates
{
	NSArray * tobeparsed = [self objectWithUrl:
										[NSURL URLWithString:
													[NSString stringWithFormat:	HALLPLATS_URL,
																				centerCoordinates.latitude,
																				centerCoordinates.longitude]]];
	
	NSMutableArray *annotationList = [NSMutableArray arrayWithCapacity:tobeparsed.count];
	for(NSDictionary *dictionary in tobeparsed){
		//[dictionary retain];
		CLLocationCoordinate2D location = {[[dictionary valueForKey:@"lat"] floatValue], [[dictionary valueForKey:@"lng"] floatValue]};
		VTAnnotation *anAnnotation = [[VTAnnotation alloc] initWithCoordinate:location];
	
		[anAnnotation setTitle:[dictionary valueForKey:@"name"] subtitle:@" "];
	
		anAnnotation.stop_name = [dictionary valueForKey:@"name"];
		
		NSArray *forecast_json = [dictionary valueForKey:@"forecast"];
		NSMutableArray *forecastList = [NSMutableArray arrayWithCapacity:forecast_json.count];
	
		for(NSArray *forecast_bundle in forecast_json){
			VTForecast *aForecast = [[VTForecast alloc] init];
			
			NSDictionary *forecast_info = [forecast_bundle objectAtIndex:1];
			
			aForecast.lineNumber		= [forecast_bundle objectAtIndex:0];
			aForecast.foregroundColor	= [self stringToColor:[forecast_info valueForKey:@"color"]];
			aForecast.backgroundColor	= [self stringToColor:[forecast_info valueForKey:@"background_color"]];
			aForecast.destination		= [forecast_info valueForKey:@"destination"];
			aForecast.nastaTime			= [forecast_info valueForKey:@"next_trip"];
			aForecast.nastaHandicap		= [[forecast_info valueForKey:@"next_handicap"] boolValue];
			aForecast.nastaLowFloor		= [[forecast_info valueForKey:@"next_low_floor"] boolValue];
			aForecast.darefterTime		= [forecast_info valueForKey:@"next_next_trip"];
			aForecast.darefterHandicap	= [[forecast_info valueForKey:@"next_next_handicap"] boolValue];
			aForecast.darefterLowFloor	= [[forecast_info valueForKey:@"next_next_low_floor"] boolValue];
			
			[forecastList addObject:aForecast];
		}
		//[forecastList sortUsingSelector:@selector(compareWith:)];

		anAnnotation.forecastList = forecastList;
	
		[anAnnotation updateDistanceFrom:centerCoordinates];
		
		[annotationList addObject:anAnnotation];
		//NSLog(@"%@", dictionary);
	}
	
	return (NSArray *)annotationList;
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											timeoutInterval:20];
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

- (id) objectWithUrl:(NSURL *)url
{
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self stringWithUrl:url];
	id object = [jsonParser objectWithString:jsonString error:NULL];
	[jsonParser release];
	[jsonString release];
	// Parse the JSON into an Object
	return object;
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
