//
//  CustomImage.m
//  CDTATicketing
//
//  Created by ibasemac3 on 3/16/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "CustomImage.h"

@implementation CustomImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setCornerRadiusWithRadius:(int)radius
{
    [self.layer setCornerRadius:radius];
    [self.layer setMasksToBounds:YES];
}


@end
