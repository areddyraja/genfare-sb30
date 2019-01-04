//
//  UIColor+HexString.h
//  CooCooBase
//
//  Micah Hainline
//  Reference: http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
