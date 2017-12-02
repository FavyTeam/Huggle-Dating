//
//  Helper.m
//  Restaurant
//
//  Created by 3Embed on 14/09/12.
//
//

#import "Helper.h"

@implementation Helper

static Helper *helper;

@synthesize _latitude;
@synthesize _longitude;

+ (id)sharedInstance {
	if (!helper) {
		helper  = [[self alloc] init];
	}
	return helper;
}

+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color
{
    lbl.textColor = color;
    if (txt != nil) {
        lbl.text = txt;
    }
    if (font != nil) {
        lbl.font = [UIFont fontWithName:font size:_size];
    }
}

+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color
{
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitleColor:t_color forState:UIControlStateNormal];
    if (s_color != nil) {
        [btn setTitleShadowColor:s_color forState:UIControlStateNormal];
    }
    if (font != nil) {
        btn.titleLabel.font = [UIFont fontWithName:font size:_size];
    }
    else{
        btn.titleLabel.font = [UIFont systemFontOfSize:_size];
    }
}

+(void)showAlertWithTitle:(NSString*)title Message:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+(void)showErrorFor:(int)errorCode
{
    //    switch (errorCode) {
    //        case SERVER_EXCEPTION:
    //            [Helper showAlertWithTitle:@"Error" Message:@"Could not connect to sever. Please try again."];
    //            break;
    //
    //        case PASSWORD_NOT_MATCH:
    //            [Helper showAlertWithTitle:@"Error" Message:@"The password you entered is incorrect. Please try again "];
    //            break;
    //        case SUCCESSFULL_RESPONSE:
    //            ;
    //            break;
    //        case REQUEST_PARAMETER_BLANK:
    //            [Helper showAlertWithTitle:@"Alert" Message:@"Please enter valid information"];
    //            break;
    //        case EMAIL_NOT_MATCH:
    //            [Helper showAlertWithTitle:@"Alert" Message:@"User already exists"];
    //            break;
    //        case SEARCH_RESULT_NULL:
    //            [Helper showAlertWithTitle:@"Message" Message:@"No Result Found"];
    //            break;
    //        case SERVICE_RESPONSE_NULL:
    //            [Helper showAlertWithTitle:@"Message" Message:@"No Result Found"];
    //            break;
    //        default:
    //            break;
    //    }
}

+ (NSString *)removeWhiteSpaceFromURL:(NSString *)url {
	NSMutableString *string = [[NSMutableString alloc] initWithString:url] ;
	[string replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
	return string;
}
+ (NSString *)stripExtraSpacesFromString:(NSString *)string {
	NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
	NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
	
	NSArray *parts = [string componentsSeparatedByCharactersInSet:whitespaces];
	NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
	
	return [filteredArray componentsJoinedByString:@" "];
}

+(NSInteger)getAge :(NSString*)date
{
    // Get current date time
    
    //NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    
    // Get the date time in NSString
    
    NSDate *dateInStringFormated = [dateFormatter dateFromString:date];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:dateInStringFormated
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return age;
}

+(NSString*)getBirthDate :(NSString*)date
{
    // Get current date time
    
    //NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    
    
    // Get the date time in NSString
    
    NSDate *dateInStringFormated = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateInString = [dateFormatter stringFromDate:dateInStringFormated];
    
    return dateInString;
    
}


+(NSString*)getCurrentTime
{
    NSDate *currentDateTime = [NSDate date];
    // Instantiate a NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    [dateFormatter setDateFormat:@"HH:mm"];
    // Get the date time in NSString
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    return dateInStringFormated;
}

+ (UIColor *)getColorFromHexString:(NSString *)hexString :(CGFloat)alphaValue {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alphaValue];
}

+(NSString *)ConverGMTtoLocal :(NSString*)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    NSDate *dateSource = [[NSDate alloc] init];
    dateSource = [df dateFromString: date];
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:sourceTimeZone];
    
    NSString *timeStamp = [df stringFromDate:dateSource];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss "];
    NSDate *dateFinal= [[NSDate alloc] init];
    dateFinal = [df dateFromString: timeStamp];
    
    NSDate* now = [NSDate date];

    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSDayCalendarUnit |NSHourCalendarUnit
                                       fromDate:dateFinal
                                       toDate:now
                                       options:0];
    
    NSString * stringDue = [NSString stringWithFormat:@"%i-d %i-",ageComponents.day, ageComponents.hour];
    return stringDue;
}

@end
