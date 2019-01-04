//
//  TileButton.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileButton : UIButton

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)btnText
               font:(UIFont *)font
               icon:(UIImage *)iconImage
     roundedCorners:(UIRectCorner)roundedCorners;

@end
